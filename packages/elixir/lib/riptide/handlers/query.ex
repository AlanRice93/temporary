defmodule Riptide.Handler.Query do
  use Riptide.Handler

  def handle_call("riptide.query", _body, state) do
    {
      :reply,
      %{
        merge: %{
          "animals" => %{
            "shark" => "hammerhead"
          }
        },
        delete: %{}
      },
      state
    }
  end
end
