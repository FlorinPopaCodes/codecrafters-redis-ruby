require 'optparse'
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
          case parsed_command[0].upcase
          when 'PING'
            client.puts "+PONG\r\n"
          when 'ECHO'
            r = parsed_command[1]
            client.puts "$#{r.size}\r\n#{r}\r\n"
          when 'INFO'
            if parsed_command[1].upcase == 'REPLICATION' # TODO: replace with casecmp?
              client.puts "$11\r\nrole:master\r\n"
            end
          when 'SET'
            if px_command_index = parsed_command[3..].index { |i| i.upcase == 'PX' }
              storage[parsed_command[1]][:expiry] =
                DateTime.now.strftime('%Q').to_i + parsed_command[px_command_index + 4].to_i
            else
              storage[parsed_command[1]][:expiry] = nil
            end

            storage[parsed_command[1]][:value] = parsed_command[2]
            client.puts "+OK\r\n"
          when 'GET'
            r = storage[parsed_command[1]][:value]

            if r && (!storage[parsed_command[1]][:expiry] || storage[parsed_command[1]][:expiry] > DateTime.now.strftime('%Q').to_i)
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


options = { port: 6379}
OptionParser.new do |opts|
  opts.banner = "Usage: server.rb [options]"

  opts.on('-p', '--port PORT', 'Listening port') { |v| options[:port] = v }

end.parse!

YourRedisServer.new(options[:port]).start
