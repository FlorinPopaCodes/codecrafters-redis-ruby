require "socket"

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
        while line = client.gets
          client.puts "+PONG\r\n" if line.downcase.start_with?('ping')
        end
        client.close
      end
    end
  end
end

YourRedisServer.new(6379).start
