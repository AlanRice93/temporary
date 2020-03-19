defmodule Riptide.Store.Benchmark do
  require Logger

  def run(store, opts) do
    store.init(opts)
    range_count = 100_000
    range = range_count..(range_count * 2)

    time("Write #{range_count} values", fn ->
      Stream.map(range, fn item ->
        Riptide.Mutation.merge(["large", inspect(item)], %{
          "key" => item,
          "created" => :os.system_time(:millisecond)
        })
      end)
      |> Riptide.Mutation.chunk(1000)
      |> Enum.each(fn mut -> Riptide.Store.mutation(mut, store, opts) end)
    end)

    read_count = 100

    time("Read #{read_count} values", fn ->
      Riptide.Store.query(
        range
        |> Enum.take_random(read_count)
        |> Enum.reduce(%{}, fn item, collect ->
          Dynamic.put(collect, ["large", inspect(item)], %{})
        end),
        store,
        opts
      )
    end)
  end

  def time(name, fun) do
    now = :os.system_time(:millisecond)
    fun.()
    result = :os.system_time(:millisecond) - now
    Logger.info(name <> ": " <> inspect(result) <> "ms")
  end
end
