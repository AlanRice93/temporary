defmodule Riptide do
  @internal %{internal: true}

  def init() do
    [
      Riptide.Config.riptide_store_read(),
      Riptide.Config.riptide_store_write()
    ]
    |> Enum.uniq()
    |> Enum.map(fn
      {store, opts} -> :ok = store.init(opts)
      _ -> :ok
    end)

    :ok
  end

  def query(query, state \\ @internal) do
    with :ok <- Riptide.Interceptor.before_query(query, state) do
      case Riptide.Interceptor.resolve_query(query, state) do
        nil -> {:ok, Riptide.Store.query(query)}
        result -> {:ok, result}
      end
    end
  end

  def query_path!(path, opts \\ %{}, state \\ @internal) do
    {:ok, result} = query_path(path, opts, state)
    result
  end

  def query_path(path, opts \\ %{}, state \\ @internal) do
    case query(Dynamic.put(%{}, path, opts), state) do
      {:ok, result} -> {:ok, Dynamic.get(result, path)}
      result -> result
    end
  end

  def mutation(mut), do: mutation(mut, %{internal: true})

  def mutation(mut, state) do
    with {:ok, before} <- Riptide.Interceptor.before_mutation(mut, state),
         :ok <- Riptide.Store.mutation(mut) do
      {:ok, before}
    end
  end

  def merge(path, value), do: mutation(Riptide.Mutation.merge(path, value))
  def merge(path, value, state), do: mutation(Riptide.Mutation.merge(path, value), state)

  def delete(path), do: mutation(Riptide.Mutation.delete(path))
  def delete(path, state), do: mutation(Riptide.Mutation.delete(path), state)
end
