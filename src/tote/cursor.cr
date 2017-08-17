module Tote
  class Cursor
    @x : Int32
    @y : Int32
    getter :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def eof(buffer)
      @y = buffer.size - 1
      @x = buffer[@y].size
    end

    def limit(buffer)
      if @x < 0
        @x = 0
      end

      if @y < 0
        @y = 0
      end

      if @y > buffer.size - 1
        @y = buffer.size - 1
      end

      if @x > buffer[@y].size
        @x = buffer[@y].size
      end
    end

    def up
      @y -= 1
    end

    def down
      @y += 1
    end

    def left
      @x -= 1
    end

    def right
      @x += 1
    end
  end
end
