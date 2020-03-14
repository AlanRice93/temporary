defmodule Riptide do
  def mutation(mut), do: mutation(mut, %{internal: true})

  def mutation(mut, state) do
    with {:ok, before} <- Riptide.Interceptor.before_mutation(mut, state) do
      {:ok, before}
    end
  end

  def merge(path, value), do: mutation(Riptide.Mutation.merge(path, value))
  def merge(path, value, state), do: mutation(Riptide.Mutation.merge(path, value), state)

  def delete(path), do: mutation(Riptide.Mutation.delete(path))
  def delete(path, state), do: mutation(Riptide.Mutation.delete(path), state)
end
