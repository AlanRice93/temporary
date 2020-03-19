defmodule Riptide.Config do
  use Brine

  config :riptide, %{
    commands: [],
    store: %{
      write: nil,
      read: nil
    },
    interceptors: []
  }
end
