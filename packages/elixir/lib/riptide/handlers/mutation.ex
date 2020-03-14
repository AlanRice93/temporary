defmodule Riptide.Handler.Mutation do
  use Riptide.Handler

  def handle_call("riptide.mutation", mut, state) do
    case Riptide.mutation(mut, state) do
      {:ok, _mut} -> {:reply, :ok, state}
      {:error, err} -> {:error, err, state}
    end
  end
end
