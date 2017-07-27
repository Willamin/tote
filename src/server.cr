require "./tote/*"
require "socket"

module Tote
  class Server
    @host = "localhost"
    @port = 1234
    @buffer = ""

    def run
      puts "Listening at #{@host} on port #{@port}"

      server = TCPServer.new(@host, @port)
      loop do
        server.accept { |c| on_connect(c) }
      end
    end

    def on_connect(client)
      message = client.gets

      return unless message

      case message
      when "request-buffer"
        output(message)
        client.print @buffer
      when "delete"
        output(message)
        @buffer = @buffer.rchop
      when "delete-word"
        output(message)
        @buffer, _, _ = @buffer.rpartition(/\W\w*?/)
      when "new-line"
        @buffer = @buffer + "\n"
      else
        output("typed #{message}")
        @buffer = @buffer + message
      end

      # puts "  buffer: #{@buffer}"
    end

    def output(command)
      puts "received command at #{Time.now.epoch}: #{command}"
    end
  end
end

tote_server = Tote::Server.new
tote_server.run
