defmodule Riptide.Test.Interceptor do
  defmodule Example do
    use Riptide.Interceptor

    def mutation_before(["animals"], %{merge: %{"shark" => shark}}, _mut, _state) do
      {:combine, Riptide.Mutation.merge(["ocean", shark], true)}
    end

    def mutation_after(["animals"], %{merge: %{"shark" => shark}}, _mut, _state) do
      Process.put(:after, true)
      :ok
    end

    def query_before(["denied" | _rest], _opts, _state) do
      {:error, :denied}
    end

    def query_resolve(["resolved" | path], _opts, _state) do
      %{
        "turtle" => "snapping"
      }
      |> Dynamic.get(path)
    end
  end

  use ExUnit.Case

  test "mutation_before" do
    Riptide.Interceptor.logging_enable()

    {
      :ok,
      %{
        merge: %{
          "ocean" => %{"hammerhead" => true}
        }
      }
    } =
      Riptide.Interceptor.mutation_before(
        Riptide.Mutation.merge(["animals", "shark"], "hammerhead"),
        %{},
        [Example]
      )
  end

  test "mutation_after" do
    Riptide.Interceptor.logging_enable()

    :ok =
      Riptide.Interceptor.mutation_after(
        Riptide.Mutation.merge(["animals", "shark"], "hammerhead"),
        %{},
        [Example]
      )
  end

  test "query_resolve" do
    %{"turtle" => "snapping"} =
      Riptide.Interceptor.query_resolve(
        %{
          "resolved" => %{}
        },
        %{},
        [Example]
      )
  end

  test "query_before" do
    {:error, :denied} =
      Riptide.Interceptor.query_before(
        %{
          "denied" => %{}
        },
        %{},
        [Example]
      )
  end
end
