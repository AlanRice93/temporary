defmodule Riptide.Test.Store do
  use ExUnit.Case

  test Riptide.Store.LMDB do
    File.rm_rf("lmdb")
    test_store(Riptide.Store.LMDB, %{directory: "lmdb"})
    File.rm_rf("lmdb")
  end

  test Riptide.Store.Memory, do: test_store(Riptide.Store.Memory, %{})
  test Riptide.Store.Multi, do: test_store(Riptide.Store.Multi, [{Riptide.Store.Memory, %{}}])

  defp test_store(store, opts) do
    :ok = store.init(opts)

    :ok =
      Riptide.Store.mutation(
        Riptide.Mutation.merge(["animals"], %{
          "shark" => "hammerhead",
          "whale" => "orca"
        }),
        store,
        opts
      )

    %{"animals" => %{"shark" => "hammerhead"}} =
      Riptide.Store.query(%{"animals" => %{"shark" => %{}}}, store, opts)

    2 = Riptide.Store.stream(["animals"], %{}, store, opts) |> Enum.count()
    1 = Riptide.Store.stream(["animals"], %{limit: 1}, store, opts) |> Enum.count()

    [{"whale", _}] =
      Riptide.Store.stream(["animals"], %{min: "whale"}, store, opts) |> Enum.to_list()

    Riptide.Store.mutation(Riptide.Mutation.delete(["animals", "whale"]), store, opts)

    %{
      "animals" => %{
        "shark" => "hammerhead"
      }
    } =
      Riptide.Store.query(
        %{
          "animals" => %{
            "shark" => %{},
            "whale" => %{}
          }
        },
        store,
        opts
      )
  end
end
