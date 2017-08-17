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
    @status : Array(String)
    @cursor : Cursor

    def initialize
      @cursor = Cursor.new(0, 0)
      @buffer = [] of String
      @status = [] of String
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

    def main_loop
      puts "Connecting to #{@host} on port #{@port}"
      loop do
        @status = [] of String
        update_buffer
        update_status
        redraw
        event = @window.peek(1000)
        if event.type == Termbox::EVENT_KEY
          case event.key
          when Termbox::KEY_CTRL_C
            break
          else
            handle_key(event.key, event.ch)
            @cursor.limit(@buffer)
          end
        end
      end
      @window.shutdown
    rescue e
      @window.shutdown
      STDERR.puts e.inspect_with_backtrace
    end

    def update_buffer
      received_buffer = send_message("request-buffer")
      @buffer = received_buffer.split("\n")
    end

    def status_maker(label)
      "#{label}:" + yield.to_s
    end

    def update_status
      @status << status_maker("size") do
        @buffer.join("\n").size
      end

      @status << status_maker("cur") do
        "[#{@cursor.x},#{@cursor.y}]"
      end

      @status << status_maker("line-length") do
        @buffer[@cursor.y].size
      end
    end

    def redraw
      @window.clear
      @window << Border.new(@window, "normal")

      @window.set_primary_colors(8, 0)
      @buffer.each_with_index do |line, i|
        @window.write_string(Position.new(1, 1 + i), line)
      end

      @window.set_primary_colors(1, 0)
      @window.write_string(
        Position.new(1, @window.height - 2),
        "#{@status.join(" ")}")


      @window.set_primary_colors(8, 0)
      @cursor.limit(@buffer)
      @window.cursor(
        Position.new(
          1 + @cursor.x,
          1 + @cursor.y))

      @window.set_primary_colors(4, 0)
      @window.render
    end

    def handle_key(key, ch)
      case key
      when Termbox::KEY_ARROW_UP, Termbox::KEY_ARROW_DOWN, Termbox::KEY_ARROW_LEFT, Termbox::KEY_ARROW_RIGHT
        move_cursor(key)
        return
      when Termbox::KEY_BACKSPACE, Termbox::KEY_BACKSPACE2
        send_message_and_update("delete")
      when Termbox::KEY_CTRL_W
        send_message_and_update("delete-word")
      when Termbox::KEY_ENTER
        send_message_and_update("new-line")
      when Termbox::KEY_SPACE
        send_message_and_update("char: ")
      else
        unless ch == 0
          send_message_and_update("char:" + ch.chr.to_s)
        end
      end
    end

    def move_cursor(key)
      case key
      when Termbox::KEY_ARROW_UP
        @cursor.up
      when Termbox::KEY_ARROW_DOWN
        @cursor.down
      when Termbox::KEY_ARROW_LEFT
        @cursor.left
      when Termbox::KEY_ARROW_RIGHT
        @cursor.right
      end
      @cursor.limit(@buffer)
    end

    def send_message_and_update(message)
      send_message(message)
      update_buffer
      @cursor.eof(@buffer)
    end

    def send_message(message)
      client = TCPSocket.new(@host, @port)
      client.puts message
      output = client.gets_to_end
      client.close
      output
    end
  end
end

Tote::Client.new.main_loop
