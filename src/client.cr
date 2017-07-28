require "./tote/*"
require "option_parser"
require "socket"
require "termbox"
include Termbox

module Tote
  class Client
    @host : String
    @port : Int32
    @buffer : Array(String)
    @window : Window
    @status : String

    def initialize
      @buffer = [] of String
      @status = ""
      @port = 1234
      @host = "localhost"
      @window = Window.new
      @window.set_output_mode(OUTPUT_256)
      @window.set_primary_colors(8, 0)
    end

    def parse_args
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

    def handle_key(key, ch)
      case key
      when Termbox::KEY_BACKSPACE, Termbox::KEY_BACKSPACE2
        send_message("delete")
      when Termbox::KEY_CTRL_W
        send_message("delete-word")
      when Termbox::KEY_ENTER
        send_message("new-line")
      when Termbox::KEY_SPACE
        send_message(" ")
      else
        unless ch == 0
          send_message(ch.chr.to_s)
        end
      end
    end

    def update_buffer
      received_buffer = send_message("request-buffer")
      @status = "#{received_buffer.size}"
      @buffer = received_buffer.split("\n")
    end

    def main_loop
      puts "Connecting to #{@host} on port #{@port}"
      loop do
        update_buffer
        redraw
        event = @window.peek(1000)
        if event.type == Termbox::EVENT_KEY
          case event.key
          when Termbox::KEY_CTRL_C
            break
          else
            handle_key(event.key, event.ch)
          end
        end
      end
      @window.shutdown
    rescue e
      @window.shutdown
      STDERR.puts e
    end

    def send_message(message)
      client = TCPSocket.new(@host, @port)
      client.puts message
      output = client.gets_to_end
      client.close
      output
    end

    def redraw
      @window.clear
      @window << Border.new(@window, "normal")

      @buffer.each_with_index do |line, i|
        @window.write_string(Position.new(1, 1 + i), line)
      end

      @window.write_string(
        Position.new(1, @window.height - 2),
        "#{@status}")

      @window.cursor(
        Position.new(
          1 + @buffer[-1].size,
          1 + @buffer.size - 1))
      @window.render
    end
  end
end

tote = Tote::Client.new
tote.main_loop
