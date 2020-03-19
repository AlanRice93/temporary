defmodule Riptide.Store.Postgres do
  @behaviour Riptide.Store
  @delimiter "×"
  def init(opts) do
    Postgrex.query!(
      opts_name(opts),
      """
      	CREATE TABLE IF NOT EXISTS "#{opts_table(opts)}" (
          path text COLLATE "C",
          value jsonb,
          PRIMARY KEY(path)
        );
      """,
      []
    )

    :ok
  end

  def opts_table(opts), do: Map.get(opts, :table, "riptide")
  def opts_name(opts), do: Map.get(opts, :name, :postgres)

  def opts_transaction_timeout(opts), do: Map.get(opts, :transaction_timeout, :timer.minutes(10))

  def mutation(merges, deletes, opts) do
    Postgrex.transaction(
      opts_name(opts),
      fn conn ->
        delete(deletes, conn, opts)
        merge(merges, conn, opts)
      end,
      timeout: :timer.hours(1)
    )
    |> case do
      {:ok, _} -> :ok
      result -> {:error, result}
    end
  end

  def merge([], _conn, _opts), do: :ok

  def merge(merges, conn, opts) do
    merges
    |> Stream.chunk_every(30000)
    |> Enum.map(fn layers ->
      {_, statement, params} =
        layers
        |> Enum.reduce({1, [], []}, fn {path, value}, {index, statement, params} ->
          {
            index + 2,
            ["($#{index}, $#{index + 1})" | statement],
            [encode_path(path), value | params]
          }
        end)

      Postgrex.query!(
        conn,
        "INSERT INTO  \"#{opts_table(opts)}\"(path, value) VALUES #{Enum.join(statement, ", ")} ON CONFLICT (path) DO UPDATE SET value = excluded.value",
        params
      )
    end)
  end

  @spec delete(any, any, any) :: :ok
  def delete([], _conn, _opts), do: :ok

  def delete(layers, conn, opts) do
    {arguments, statement} =
      layers
      |> Enum.with_index()
      |> Stream.map(fn {{path, _}, index} ->
        {[encode_path(path) <> "%"], "(path LIKE $#{index + 1})"}
      end)
      |> Enum.reduce({[], []}, fn {args, field}, {a, b} -> {args ++ a, [field | b]} end)

    statement = Enum.join(statement, " OR ")

    Postgrex.query!(
      conn,
      "DELETE FROM \"#{opts_table(opts)}\" WHERE #{statement}",
      arguments
    )

    :ok
  end

  def encode_prefix(path) do
    Enum.join(path, @delimiter)
  end

  def encode_path(path) do
    Enum.join(path, @delimiter) <> @delimiter
  end

  def decode_path(input) do
    String.split(input, @delimiter, trim: true)
  end

  def query(paths, store_opts) do
    {cases, wheres, args, _} =
      Enum.reduce(paths, {[], [], [], 0}, fn {path, opts}, {cases, wheres, args, count} ->
        combined = encode_prefix(path)
        {min, max} = Riptide.Store.Prefix.range(combined, opts)

        {
          cases ++ ["(path >= $#{count + 2} AND path < $#{count + 3}) THEN $#{count + 1}"],
          wheres ++ ["(path >= $#{count + 2} AND path < $#{count + 3})"],
          args ++ [combined, encode_path(min), encode_path(max)],
          count + 3
        }
      end)

    statement = """
      SELECT *,
        CASE WHEN
          #{Enum.join(cases, "\nWHEN")}
        END as prefix
      FROM #{opts_table(store_opts)}
      WHERE
        #{Enum.join(wheres, "OR")}
    """

    Postgrex.query!(opts_name(store_opts), statement, args)
    |> Map.get(:rows)
    |> Stream.map(fn [path, value, prefix] ->
      {decode_path(prefix), decode_path(path), value}
    end)
    |> Stream.chunk_by(fn {prefix, _path, _value} -> prefix end)
    |> Stream.map(fn chunk ->
      {group, _, _} = Enum.at(chunk, 0)
      {group, Stream.map(chunk, fn {_, path, value} -> {path, value} end)}
    end)
  end
end
