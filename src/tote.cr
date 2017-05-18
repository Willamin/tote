require "./tote/*"
require "option_parser"
require "socket"

module Tote
  class Client

    @host = "localhost"
    @port = 1234
    @client = nil

    def run
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

      puts "Connecting to #{@host} on port #{@port}"
      @client = TCPSocket.new(@host, @port)

      @client.try do |client|
        message = "hello world!"
        puts "Sending: #{message}"
        client << message
        client.close
      end
    end
  end
end

tote = Tote::Client.new
tote.run()
