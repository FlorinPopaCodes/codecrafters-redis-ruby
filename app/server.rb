require 'socket'
require 'date'
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
    storage = Hash.new { |k, v| k[v] = { expiry: nil } }
    server = TCPServer.new(@port)
    loop do
      Thread.new(server.accept) do |client|
        while parsed_command = Parser.parse(client)
          command_time = DateTime.now.strftime('%Q').to_i

          case parsed_command[0].upcase
          when 'PING'
            client.puts "+PONG\r\n"
          when 'ECHO'
            r = parsed_command[1]
            client.puts "$#{r.size}\r\n#{r}\r\n"
          when 'SET'
            if px_command_index = parsed_command[3..].index { |i| i.upcase == 'PX' }
              storage[parsed_command[1]][:expiry] =
                command_time + parsed_command[px_command_index + 1].to_i
            else
              storage[parsed_command[1]][:expiry] = nil
            end

            storage[parsed_command[1]][:value] = parsed_command[2]
            client.puts "+OK\r\n"
          when 'GET'
            r = storage[parsed_command[1]][:value]
            puts(storage[parsed_command[1]])
            puts(command_time)
            if r && (!storage[parsed_command[1]][:expiry] || storage[parsed_command[1]][:expiry] > command_time)
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
