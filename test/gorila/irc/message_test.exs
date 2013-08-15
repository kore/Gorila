defmodule GorilaIrcMessageTest do
  use ExUnit.Case

  test "Parse empty IRC message" do
    assert(
      nil == Gorila.Irc.Message.parse("")
    )
  end

  test "Parse incomplete IRC message" do
    assert(
      nil == Gorila.Irc.Message.parse("NICK :kore")
    )
  end

  test "Parse simple IRC message" do
    assert(
      Gorila.Irc.Message.Message.new(
        command: "SERVER",
        params: ["test.oulu.fi", "1"],
        text: "[tolsun.oulu.fi] Experimental server"
      ) ==
      Gorila.Irc.Message.parse("SERVER test.oulu.fi 1 :[tolsun.oulu.fi] Experimental server\r\n")
    )
  end

  test "Parse first IRC message from string" do
    assert(
      Gorila.Irc.Message.Message.new(
        command: "USER",
        params: ["guest", "tolmoon", "tolsun"],
        text: "Ronnie Regan"
      ) ==
      Gorila.Irc.Message.parse("USER guest tolmoon tolsun :Ronnie Regan\r\nNICK :Wiz")
    )
  end

  test "Parse first IRC message from server" do
    assert(
      Gorila.Irc.Message.Message.new(
        server: "csd.bu.edu",
        command: "WALLOPS",
        text: "Connect '*.uiuc.edu 6667' from Joshua"
      ) ==
      Gorila.Irc.Message.parse(":csd.bu.edu WALLOPS :Connect '*.uiuc.edu 6667' from Joshua\r\n")
    )
  end

  test "Parse first IRC message from other user" do
    assert(
      Gorila.Irc.Message.Message.new(
        nick: "john",
        ident: "~jsmith",
        host: "example.com",
        command: "PRIVMSG",
        params: ["#test"],
        text: "Hello world!"
      ) ==
      Gorila.Irc.Message.parse(":john!~jsmith@example.com PRIVMSG #test :Hello world!\r\n")
    )
  end

  test "Parse initial XChat message" do
    assert(
      Gorila.Irc.Message.Message.new(
        command: "CAP",
        params: ["LS"]
      ) ==
      Gorila.Irc.Message.parse("CAP LS\r\n")
    )
  end
end
