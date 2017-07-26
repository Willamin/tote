require "./tote/*"
require "option_parser"
require "socket"
require "termbox"
include Termbox

module Tote
  class Client
    ESC = '\u001b'

    CTRLC     = '\u{3}'
    CTRLW     = '\u{17}'
    BACKSPACE = '\u{7f}'
    RETURN = '\r'

    CLEARSCREEN = "#{ESC}[2J"
    CLEARLINE  = "#{ESC}[2K"
    CURSORHOME  = "#{ESC}[H"

    UP    = "#{ESC}[A"
    DOWN  = "#{ESC}[B"
    LEFT  = "#{ESC}[C"
    RIGHT = "#{ESC}[D"

    @host = "localhost"
    @port = 1234
    @buffer = ""

    def setup
      OptionParser.parse! do |parser|
        parser.banner = "Usage: tote [arguments] [file]"
        parser.on("-v", "--version", "Show the version number") {
          puts Tote::Client::VERSION
        }
        parser.on("-h", "--help", "Show this help message") { puts parser }
        parser.on(
          "-p PORT", "--port PORT", "Port for using an alternate tote server") { |arg| @port = arg.to_i32 }
        parser.on(
          "-h HOST", "--host HOST", "Host for using an alternate tote server") { |arg| @host = arg }
      end
    end

    def run
      puts "Connecting to #{@host} on port #{@port}"
      @buffer = send_message("request-buffer")
      redraw
      loop do
        byte = STDIN.raw &.read_char
        case byte
        when CTRLC
          break
        when BACKSPACE
          send_message("delete")
        when CTRLW
          send_message("delete-word")
        when RETURN
          send_message("new-line")
        else
          send_message(byte)
        end

        @buffer = send_message("request-buffer")
        redraw
      end
    end

    def send_message(message)
      client = TCPSocket.new(@host, @port)
      client.puts message
      output = client.gets_to_end
      client.close
      output
    end

    def clear()
      print CLEARSCREEN
      print CURSORHOME
    end

    def redraw()
      clear
      puts @buffer
    end
  end
end

tote = Tote::Client.new
tote.setup
tote.run
