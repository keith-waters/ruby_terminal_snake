require "curses"

class SnakeGame
  def initialize(window)
    @window = window
    @direction = 'u'
  end

  def input_listener
    Thread.new do
      @window.keypad = true
      while true
        input = @window.getch
        if input == Curses::Key::LEFT 
          @direction = 'l'
        elsif input == Curses::Key::RIGHT
          @direction = 'r'
        elsif input == Curses::Key::UP
          @direction = 'u'
        elsif input == Curses::Key::DOWN
          @direction = 'd'
        end
      end
    end
  end

  def startGame
    @window.box("\u2588", "\u2584", "\u2588")
    @window.setpos(2, 2)
    @window.addstr("0")
    @window.refresh

    snake = [[9, 10], [10, 10], [10, 11], [10, 12], [10, 13], [10, 14]]

    input_listener
    while true
      snake.each_with_index do |point, index| 
        c = '*'
        @window.setpos(point[0], point[1])
        @window.addstr(c)
        @window.refresh
        sleep 0.05
      end

      new_head = if @direction == 'u'
        [snake[0][0]-1, snake[0][1]]
      elsif @direction == 'd'
        [snake[0][0]+1, snake[0][1]]
      elsif @direction == 'r'
        [snake[0][0], snake[0][1]+1]
      elsif @direction == 'l'
        [snake[0][0], snake[0][1]-1]
      end

      snake = snake.unshift(new_head)
      snake.pop  

      # collision detection!
      # 32 is ' '
      # 42 is '*'
      # 48 is '0'
      # ascii conversion chart: https://bournetocode.com/projects/GCSE_Computing_Fundamentals/pages/img/ascii_table_lge.png
      # use constants for these ascii codes, more readable, better documentation
      @window.setpos(new_head[0], new_head[1])
      tester = @window.inch()
      if tester != 32
        @window.setpos(@window.cury/2-1, @window.curx/2-1)
        @window.addstr(' GAME OVER ')
      end

      @window.setpos(@window.cury, @window.curx-1)
      @window.addstr(' ')
    end
  end

end

Curses.init_screen
Curses.curs_set(0)  # Invisible cursor
begin
  window = Curses::Window.new(Curses.lines / 2 - 1, Curses.cols / 2 - 1, 0, 0)
  game = SnakeGame.new(window)
  game.startGame
ensure
  Curses.close_screen
end