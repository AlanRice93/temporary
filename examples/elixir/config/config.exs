import Config

config :riptide,
  store: %{
    write: {Riptide.Store.LMDB, %{directory: "data"}},
    read: {Riptide.Store.LMDB, %{directory: "data"}}
  }
