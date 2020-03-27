defmodule Riptide.Handler.Mutation do
  @moduledoc false
  use Riptide.Handler

  def handle_call("riptide.mutation", mut, state) do
    Riptide.Mutation.new(mut["merge"] || %{}, mut["delete"] || %{})
    |> Riptide.mutation(state)
    |> case do
      {:ok, _mut} -> {:reply, :ok, state}
      {:error, err} -> {:error, err, state}
    end
  end
end
