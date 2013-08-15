defmodule Gorila.Irc.Message do
  @moduledoc """
  Simple module to parse IRC messages into a record representing them.
  """

  @doc """
  If the string contains a IRC message, it iwll be parsed into a Message
  record. Otherwise this function will return NIL.
  """
  @spec parse(String) :: Message
  def parse(string) when is_binary(string) do
    {_, pattern} = Regex.compile(
      "\\A(?::(\\S+)\\s*)?([A-Za-z]+|\\d{3})((?:\\s+[^:\\s]\\S*)*)(?:\\s+:(.*?))?\\s*?\\r?\\n",
      "m"
    )
    cond do
      Regex.match?(pattern, string) ->
        message = createMessage(Regex.run(pattern, string))
      true ->
        nil
    end
  end

  defp createMessage([_all, server, command, params, text]) do
    message = Gorila.Irc.Message.Message.new(
      command: command,
      params: Enum.filter(
        String.split(params),
        fn (string) -> String.length(string) > 0 end
      ),
      text: text
    )
    parseServer(message, server)
  end

  defp createMessage([_all, server, command, params]) do
    message = Gorila.Irc.Message.Message.new(
      command: command,
      params: Enum.filter(
        String.split(params),
        fn (string) -> String.length(string) > 0 end
      )
    )
    parseServer(message, server)
  end

  defp parseServer(message, server) do
    {_, pattern} = Regex.compile("^(\\S*)!(\\S*)@(\\S*)$")
    # We cannot use Regexp in guards, this is why we are using a condition
    # here. Wonder if there is a more beautiful way to do this…
    cond do
      Regex.match?(pattern, server) ->
        [_all, nick, ident, host] = Regex.run(pattern, server)
        message
          .nick(nick)
          .ident(ident)
          .host(host)
      String.length(server) == 0 ->
        message
      true ->
        message.server(server)
    end
  end

  defrecord Message,
    server: nil,
    nick: nil,
    ident: nil,
    host: nil,
    command: nil,
    params: [],
    text: nil
end

defimpl Binary.Chars, for: Gorila.Irc.Message.Message do
  def to_binary(message) do
    "#{message.command} #{List.foldl(
      message.params,
      "",
      fn (x, acc) -> x <> acc end
    )} :#{message.text}"
  end
end
