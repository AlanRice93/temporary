defmodule Riptide.Handler.Query do
  use Riptide.Handler

  def handle_call("riptide.query", query, state) do
    case Riptide.query(query, state) do
      {:error, msg} ->
        {:error, msg, state}

      {:ok, result} ->
        {:reply,
         query
         |> Riptide.Query.flatten()
         |> Stream.filter(fn {_path, opts} -> opts == %{} end)
         |> Stream.map(fn {path, _} -> Riptide.Mutation.delete(path) end)
         |> Riptide.Mutation.combine()
         |> Riptide.Mutation.merge([], result), state}
    end
  end
end
