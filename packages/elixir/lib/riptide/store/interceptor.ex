defmodule Riptide.Interceptor do
  require Logger

  def before_query(query, state),
    do: before_query(query, state, Riptide.Config.riptide_interceptors())

  def before_query(query, state, interceptors) do
    query
    |> trigger_query(interceptors, :before_query, [state])
    |> Enum.find_value(fn
      {_mod, nil} -> nil
      {_mod, :ok} -> nil
      {_, result} -> result
    end)
    |> case do
      nil -> :ok
      result -> result
    end
  end

  def before_mutation(mutation, state),
    do: before_mutation(mutation, state, Riptide.Config.riptide_interceptors())

  def before_mutation(mutation, state, interceptors) do
    mutation
    |> trigger_mutation(interceptors, :before_mutation, [
      mutation,
      state
    ])
    |> Enum.reduce_while({:ok, mutation}, fn {mod, item}, {:ok, collect} ->
      case item do
        nil ->
          {:cont, {:ok, collect}}

        :ok ->
          {:cont, {:ok, collect}}

        {:combine, next} ->
          {:cont, {:ok, Riptide.Mutation.combine(collect, next)}}

        result = {:error, _} ->
          {:halt, result}

        _ ->
          {:halt, {:error, {:invalid_interceptor, mod}}}
      end
    end)
  end

  def resolve_query(query, state),
    do: resolve_query(query, state, Riptide.Config.riptide_interceptors())

  def resolve_query(query, state, interceptors) do
    query
    |> trigger_query(interceptors, :resolve_query, [state])
    |> Enum.find_value(fn
      {_mod, nil} -> nil
      {_, result} -> result
    end)
  end

  defp trigger_query(query, interceptors, fun, args) do
    layers = Riptide.Query.flatten(query)

    interceptors
    |> Stream.flat_map(fn mod ->
      Stream.map(layers, fn {path, opts} ->
        result = apply(mod, fun, [path, opts | args])

        if logging?() and result != nil,
          do: Logger.info("#{mod} #{fun} #{inspect(path)} -> #{inspect(result)}")

        {mod, result}
      end)
    end)
  end

  defp trigger_mutation(mut, interceptors, fun, args) do
    layers = Riptide.Mutation.layers(mut)

    interceptors
    |> Stream.flat_map(fn mod ->
      Stream.map(layers, fn {path, data} -> {mod, apply(mod, fun, [path, data | args])} end)
    end)
  end

  def logging?() do
    Keyword.get(Logger.metadata(), :interceptor) == true
  end

  def logging_enable() do
    Logger.metadata(interceptor: true)
  end

  def logging_disable() do
    Logger.metadata(interceptor: false)
  end

  @callback resolve_query(path :: list(String.t()), opts :: map, state :: any) ::
              {:ok, any} | {:error, term} | nil

  @callback before_query(path :: list(String.t()), opts :: map, state :: any) ::
              {:ok, any} | {:error, term} | nil

  @callback before_mutation(
              path :: list(String.t()),
              layer :: Riptide.Mutation.t(),
              mut :: Riptide.Mutation.t(),
              state :: String.t()
            ) :: :ok | {:error, term} | {:combine, Riptide.Mutation.t()}

  @callback effect(
              path :: list(String.t()),
              layer :: Riptide.Mutation.t(),
              mut :: Riptide.Mutation.t(),
              state :: String.t()
            ) :: :ok | {atom(), atom(), list(String.t())} | {atom(), list(String.t())}

  defmacro __using__(_opts) do
    quote do
      @behaviour Riptide.Interceptor
      @before_compile Riptide.Interceptor
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def before_mutation(_path, _layer, _mutation, _state), do: nil
      def before_query(_path, _opts, _state), do: nil
      def resolve_query(_path, _opts, _state), do: nil
      def effect(_path, _layer, _mutation, _state), do: nil
    end
  end
end
