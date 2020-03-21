defmodule Riptide.Test.Subscribe do
  use ExUnit.Case

  test "implementation" do
    Riptide.Subscribe.watch([])

    mut = Riptide.Mutation.merge(["animals", "shark"], "hammerhead")
    Riptide.Subscribe.broadcast_mutation(mut)

    {:mutation, ^mut} =
      receive do
        result -> result
      end
  end
end
