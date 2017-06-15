require "./totes/*"
require "socket"

module Totes
  class Server

    @host = "localhost"
    @port = 1234
    @buffer = ""

    def run
      puts "Listening at #{@host} on port #{@port}"

      server = TCPServer.new(@host, @port)
      loop do
        server.accept do |client|
          message = client.gets
          if message
            if message == "^H"
              @buffer = @buffer.rchop
            else
              @buffer = @buffer + message
            end
            puts "Buffer: #{@buffer}"
          end
        end
      end
    end
  end
end

tote_server = Totes::Server.new
tote_server.run()
