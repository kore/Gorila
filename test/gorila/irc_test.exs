defmodule GorilaIrcTest do
  use ExUnit.Case

  test "Parse simple IRC message" do
    assert(
      Gorila.Irc.Message.new(
        command: "SERVER",
        params: ["test.oulu.fi", "1"],
        text: "[tolsun.oulu.fi] Experimental server"
      ) ==
      Gorila.Irc.parse("SERVER test.oulu.fi 1 :[tolsun.oulu.fi] Experimental server\r\n")
    )
  end
end
