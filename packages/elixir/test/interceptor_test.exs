defmodule Riptide.Test.Interceptor do
  defmodule Example do
    use Riptide.Interceptor

    def before_mutation(["animals"], %{merge: %{"shark" => shark}}, _mut, _state) do
      {:combine, Riptide.Mutation.merge(["ocean", shark], true)}
    end

    def before_query(["denied" | _rest], _opts, _state) do
      {:error, :denied}
    end

    def resolve_query(["resolved" | path], _opts, _state) do
      %{
        "turtle" => "snapping"
      }
      |> Dynamic.get(path)
    end
  end

  use ExUnit.Case

  test "before_mutation" do
    Riptide.Interceptor.logging_enable()

    {
      :ok,
      %{
        merge: %{
          "ocean" => %{"hammerhead" => true}
        }
      }
    } =
      Riptide.Interceptor.before_mutation(
        Riptide.Mutation.merge(["animals", "shark"], "hammerhead"),
        %{},
        [Example]
      )
  end

  test "resolve_query" do
    %{"turtle" => "snapping"} =
      Riptide.Interceptor.resolve_query(
        %{
          "resolved" => %{}
        },
        %{},
        [Example]
      )
  end

  test "before_query" do
    {:error, :denied} =
      Riptide.Interceptor.before_query(
        %{
          "denied" => %{}
        },
        %{},
        [Example]
      )
  end
end
