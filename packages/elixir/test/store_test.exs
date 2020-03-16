defmodule Riptide.Test.Store do
  use ExUnit.Case

  test Riptide.Store.Memory, do: test_store(Riptide.Store.Memory, %{})

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

    2 = Riptide.Store.stream(["animals"]) |> Enum.count()
    1 = Riptide.Store.stream(["animals"], %{limit: 1}) |> Enum.count()
    [{"whale", _}] = Riptide.Store.stream(["animals"], %{min: "whale"}) |> Enum.to_list()

    %{
      "animals" => %{
        "shark" => "hammerhead",
        "whale" => "orca"
      }
    } =
      Riptide.Store.query(%{
        "animals" => %{
          "shark" => %{},
          "whale" => %{}
        }
      })
  end
end
