defmodule Riptide.Config do
  use Brine

  config :riptide, %{
    commands: [],
    interceptors: [
      Riptide.Interceptor.Sample
    ]
  }
end
