require "./totes/*"
require "socket"

module Totes
  class Server

    @host = "localhost"
    @port = 1234

    def run
      puts "Listening at #{@host} on port #{@port}"

      server = TCPServer.new(@host, @port)
      loop do
        server.accept do |client|
          loop do
            message = client.gets
            if message
              puts "Received: #{message}"
            end
          end
        end
      end
    end
  end
end

tote_server = Totes::Server.new
tote_server.run()
