defmodule Riptide.Subscribe do
  def watch(path), do: watch(path, self())

  def watch(path, pid) do
    group = group(path)

    cond do
      member?(group, pid) ->
        :ok

      true ->
        group
        |> :pg2.join(pid)
        |> case do
          {:error, {:no_such_group, group}} ->
            :pg2.create(group)
            watch(path, pid)

          :ok ->
            :ok
        end
    end
  end

  def member?(group, pid) do
    pid in :pg2.get_members(group)
  end

  def broadcast_mutation(mut) do
    mut
    |> Riptide.Mutation.layers()
    |> Enum.each(fn {path, value} ->
      inflated = Riptide.Mutation.inflate(path, value)

      path
      |> group
      |> :pg2.get_members()
      |> case do
        {:error, _} ->
          :skip

        members ->
          Enum.map(members, fn pid -> send(pid, {:mutation, inflated}) end)
      end
    end)
  end

  def group(path) do
    {__MODULE__, path}
  end
end
