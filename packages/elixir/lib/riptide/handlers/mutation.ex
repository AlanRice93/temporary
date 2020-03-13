defmodule Riptide.Handler.Mutation do
  use Riptide.Handler

  def handle_call("riptide.mutation", _body, state) do
    {:reply, "ok", state}
  end
end
