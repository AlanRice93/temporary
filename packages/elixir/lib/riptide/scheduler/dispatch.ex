defmodule Riptide.Scheduler do
  require Logger
  use GenServer

  @root "riptide:scheduler"

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    send(self(), :reload)
    {:ok, %{}}
  end

  def handle_info(:reload, state) do
    [@root]
    |> Riptide.stream()
    |> Enum.each(fn
      {task, %{"timestamp" => ts}} -> schedule(task, ts)
      _ -> :ok
    end)

    {:noreply, state}
  end

  def handle_info({:trigger, key}, state) do
    Task.start_link(fn -> execute(key) end)
    {:noreply, state}
  end

  def info(task), do: Riptide.query_path!([@root, task])

  def cancel(task) do
    Riptide.Mutation.delete([@root, task])
  end

  def schedule_in(mod, fun, args, offset, key \\ nil),
    do: schedule(:os.system_time(:millisecond) + offset, mod, fun, args, key)

  def schedule(timestamp, mod, fun, args, key \\ nil) do
    key = key || "SCH" <> Riptide.UUID.ascending()

    Riptide.Mutation.merge([@root, key], %{
      "key" => key,
      "timestamp" => timestamp,
      "mod" => mod,
      "fun" => fun,
      "args" => args,
      "count" => 0
    })
  end

  def execute(task) do
    task
    |> info()
    |> case do
      info = %{
        "mod" => mod,
        "args" => args,
        "fun" => fun,
        "timestamp" => timestamp
      } ->
        Logger.metadata(scheduler_mod: mod, scheduler_fun: fun)
        mod = String.to_atom(mod)
        fun = String.to_atom(fun)

        try do
          apply(mod, fun, args)

          cond do
            timestamp === Riptide.query_path!([@root, task, "timestamp"]) ->
              Riptide.delete!([@root, task])

            true ->
              Riptide.merge!([@root, task, "count"], 0)
          end

          {:stop, :normal, task}
        rescue
          e ->
            :error
            |> Exception.format(e, __STACKTRACE__)
            |> Logger.error(crash_reason: {e, __STACKTRACE__})

            count = (info["count"] || 0) + 1
            Riptide.merge!([@root, task, "count"], count)

            Riptide.Retry.Basic
            |> apply(:retry, [task, count])
            |> case do
              {:delay, amount} ->
                Process.send_after(__MODULE__, {:trigger, task}, amount)

              :abort ->
                Riptide.delete!([@root, task])
            end
        end

      _ ->
        :ok
    end
  end

  def schedule(key, timestamp) do
    offset = max(0, timestamp - :os.system_time(:millisecond))
    Process.send_after(__MODULE__, {:trigger, key}, offset)
  end
end
