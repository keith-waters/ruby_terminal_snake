require "curses"

class SnakeGame
  def initialize(window)
    @window = window
    @direction = 'u'
    @snake = [[10, 10]]
  end

  def input_listener
    Thread.new do
      @window.keypad = true
      while true
        input = @window.getch
        if input == Curses::Key::LEFT then @direction = 'l'
        elsif input == Curses::Key::RIGHT then @direction = 'r'
        elsif input == Curses::Key::UP then @direction = 'u'
        elsif input == Curses::Key::DOWN then @direction = 'd'
        end
      end
    end
  end

  def remove_tail
    x, y = @snake.last
    @window.setpos(x, y)
    @window.addstr(' ')
    @snake.pop
  end

  def grow_snake
    c = '*'
    head = @snake.first
    @window.setpos(*head)
    @window.addstr(c)
  end

  def move_snake
    x, y = @snake.first
    new_head = if @direction == 'u'
      [x-1, y]
    elsif @direction == 'd'
      [x+1, y]
    elsif @direction == 'r'
      [x, y+1]
    elsif @direction == 'l'
      [x, y-1]
    end
    @snake.unshift(new_head)
    handle_collision
    grow_snake
  end

  def spawn_food
    x = rand(2..@window.maxx-2)
    y = rand(2..@window.maxy-2)
    @window.setpos(y, x)
    @window.addstr("0")
  end

  def handle_collision
    # collision detection!
    # 32 is ' '
    # 42 is '*'
    # 48 is '0'
    # ascii conversion chart: https://bournetocode.com/projects/GCSE_Computing_Fundamentals/pages/img/ascii_table_lge.png
    # use constants for these ascii codes, more readable, better documentation
    x, y = @snake.first
    @window.setpos(x, y)
    tester = @window.inch()
    return remove_tail if tester == ' '.ord
    return spawn_food if tester == '0'.ord

    @window.setpos(@window.cury/2-1, @window.curx/2-1)
    @window.addstr(' GAME OVER ')
  end

  def startGame
    spawn_food
    input_listener
    while true
      move_snake
      @window.refresh
      sleep 0.15
    end
  end

end

Curses.init_screen
Curses.curs_set(0)  # Invisible cursor
begin
  window = Curses::Window.new(Curses.lines / 2 - 1, Curses.cols / 2 - 1, 0, 0)
  window.box("\u2588", "\u2584", "\u2588")
  window.refresh

  game = SnakeGame.new(window)
  game.startGame
ensure
  Curses.close_screen
end