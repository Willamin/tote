require "./tote/*"
require "option_parser"
require "socket"

module Tote
  class Client

    CTRLC = '\u{3}'
    CTRLW = '\u{17}'
    BACKSPACE = '\u{7f}'

    @host = "localhost"
    @port = 1234

    def setup
      OptionParser.parse! do |parser|
        parser.banner = "Usage: tote [arguments] [file]"
        parser.on("-v", "--version", "Show the version number") {
          puts Tote::VERSION
        }
        parser.on("-h", "--help", "Show this help message") { puts parser }
        parser.on(
          "-p PORT", "--port PORT", "Port for using an alternate tote server"
        ) { |arg| @port = arg.to_i32 }
        parser.on(
          "-h HOST", "--host HOST", "Host for using an alternate tote server"
        ) { |arg| @host = arg }
      end
    end

    def run
      puts "Connecting to #{@host} on port #{@port}"
      loop do
        byte = STDIN.raw &.read_char
        case byte
        when CTRLC
          break
        when BACKSPACE
          send_message("delete")
        when CTRLW
          send_message("delete-word")
        else
          send_message(byte)
        end

        buffer = send_message("request-buffer")
        puts buffer
      end
    end

    def send_message(message)
      client = TCPSocket.new(@host, @port)
      client.puts message
      output = client.gets
      client.close
      output
    end
  end
end

tote = Tote::Client.new
tote.setup()
tote.run()
