require "./tote/*"
require "option_parser"
require "socket"

module Tote
  class Client

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
      send_message "hello world!\n"
    end

    def send_message(message)
      client = TCPSocket.new(@host, @port)
      puts "Sending: #{message}"
      client << message
      client.close
    end
  end
end

tote = Tote::Client.new
tote.setup()
tote.run()
