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
    storage = {}
    server = TCPServer.new(@port)
    loop do
      Thread.new(server.accept) do |client|
        while parsed_command = Parser.parse(client)

          case parsed_command[0].upcase
          when 'PING'
            client.puts "+PONG\r\n"
          when 'ECHO'
            r = parsed_command[1]
            client.puts "$#{r.size}\r\n#{r}\r\n"
          when 'SET'
            storage[parsed_command[1]] = parsed_command[2]
            client.puts "+OK\r\n"
          when 'GET'
            p parsed_command
            r = storage[parsed_command[1]]
            if r
              client.puts "$#{r.size}\r\n#{r}\r\n"
            else
              client.puts "$-1\r\n"
            end
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
