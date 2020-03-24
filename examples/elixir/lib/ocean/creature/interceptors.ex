# Example mutation that would trigger these interceptors
#
# %{
#   merge: %{
#     "creatures" => %{
#       "001" => %{
#         "key" => "001",
#         "name" => "Great White Shark"
#       }
#     }
#   },
#  delete: %{}
# }

defmodule Ocean.Creature.Created do
  use Riptide.Interceptor

  def mutation_before(["creatures", key], %{merge: %{"key" => _}}, _mut, _state) do
    {
      :combine,
      Riptide.Mutation.merge(["creatures", key, "created"], :os.system_time(:millisecond))
    }
  end
end

defmodule Ocean.Creature.Alert do
  use Riptide.Interceptor
  require Logger

  def mutation_effect(
        ["creatures", key],
        %{merge: %{"key" => key, "name" => name}},
        _mut,
        _state
      ),
      do: {:trigger, [key, name]}

  def trigger(key, name) do
    Logger.info("Alert! Creature #{name} was created")
  end
end
