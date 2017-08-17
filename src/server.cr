require "./tote/*"
require "socket"

module Tote
  class Server
    @host = "localhost"
    @port = 1234
    @buffer = ""

    def main_loop
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
        split = message.split(":")
        if split.size > 0
          if split[0] == "char"
            if split.size > 1
              @buffer = @buffer + split[1]
            end
          end
        else
          output("something else maybe")
        end
      end
    end

    def output(command)
      puts "received command at #{Time.now.epoch}: #{command}"
    end
  end
end

tote = Tote::Server.new
tote.main_loop
