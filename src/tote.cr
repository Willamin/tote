require "./tote/*"
require "option_parser"

module Tote
  class Client

    @socket = "" 

    def run
      OptionParser.parse! do |parser|
        parser.banner = "Usage: tote [arguments] [file]"
        parser.on("-v", "--version", "Show the version number") {
          puts Tote::VERSION
        }
        parser.on("-h", "--help", "Show this help message") { puts parser }
        parser.on(
          "-s SOCKET", "--server SOCKET", "Use alternate tote server"
        ) { |arg| @socket = arg }
      end

      puts @socket
    end

  end
end

tote = Tote::Client.new
tote.run()
