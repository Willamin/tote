require "./tote/*"
require "option_parser"
require "socket"
require "termbox"
include Termbox

module Tote
  class Client
    @host = "localhost"
    @port = 1234
    @buffer = [] of String
    @window = Window.new

    def setup
      @window.set_output_mode(OUTPUT_256)
      @window.set_primary_colors(8, 0)
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
      loop do
        @buffer = send_message("request-buffer").split("\n")
        redraw
        event = @window.peek(1000)
        if event.type == Termbox::EVENT_KEY
          case event.key
          when Termbox::KEY_CTRL_C
            break
          when Termbox::KEY_BACKSPACE, Termbox::KEY_BACKSPACE2
            send_message("delete")
          when Termbox::KEY_CTRL_W
            send_message("delete-word")
          when Termbox::KEY_ENTER
            send_message("new-line")
          when Termbox::KEY_SPACE
            send_message(" ")
          else
            unless event.ch == 0
              send_message(event.ch.chr.to_s)
            end
          end
        end
      end
      @window.shutdown
    end

    def send_message(message)
      client = TCPSocket.new(@host, @port)
      client.puts message
      output = client.gets_to_end
      client.close
      output
    end

    def redraw()
      @window.clear()
      @window << Border.new(@window, "normal")

      @buffer.each_with_index do |line, i|
        @window.write_string(Position.new(1, 1 + i), line)
      end

      @window.write_string(
        Position.new(1, @window.height - 2),
        "#{@buffer[0].size}, #{@buffer.size}")

      @window.cursor(
        Position.new(
          1 + @buffer[-2].size,
          1 + @buffer.size - 2))
      @window.render()
    end
  end
end

tote = Tote::Client.new
tote.setup
tote.run
