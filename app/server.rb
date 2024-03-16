require 'socket'
require_relative 'command'
require_relative 'parser'

class YourRedisServer
  def initialize(port)
    @port = port
  end

  def start
    # You can use print statements as follows for debugging, they'll be visible when running tests.
    # puts("Logs from your program will appear here!")

    # TODO: EventLoop
    server = TCPServer.new(@port)
    loop do
      Thread.new(server.accept) do |client|
        while parsed_command = Parser.parse(client)

          case parsed_command[0].upcase
          when 'PING'
            client.puts "+PONG\r\n"
          when 'ECHO'
            client.puts "$#{parsed_command[1].size}\r\n#{parsed_command[1]}\r\n"
          else
            # p parsed_command[0].upcase
          end
        end
        client.close
      end
    end
  end
end

YourRedisServer.new(6379).start
