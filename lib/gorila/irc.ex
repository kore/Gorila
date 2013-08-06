defmodule Gorila.Irc do

  def parse(string) when is_binary(string) do
    [_all, server, command, params, text] = Regex.run(
      %r/\A(?::(\S+)\s*)?([A-Za-z]+|\d{3})((?:\s+[^:\s]\S*)*)(?:\s+:(.*))?\s*?$/m,
      string
    )
    message = Gorila.Irc.Message.new(
      command: command,
      params: String.split(params),
      text: String.strip(text)
    )
    parseServer(message, server)
  end

  defp parseServer(message, server) do
    {_, pattern} = Regex.compile("^(\\S*)!(\\S*)@(\\S*)$")
    cond do
      Regex.match?(pattern, server) ->
        [_all, nick, ident, host] = Regex.run(pattern, server)
        message = message
          .nick(nick)
          .ident(ident)
          .host(host)
      true ->
        message = message.server(server)
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
