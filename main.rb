require "curses"

# snake
# - draw a bordered window
# - draw a food on in window and remenber its position
#   - at a random position
# - draw a snake
#   - store snake in an array
# - control the snake in 4 directions
#    - can get keypresses
#    - non-blocking
# - snake keeps moving
#   - game loop 
# - snake grow
# - game over if snake touches itself
# - game over if collide with walls


Curses.init_screen
Curses.curs_set(0)  # Invisible cursor

begin
  win1 = Curses::Window.new(Curses.lines / 2 - 1, Curses.cols / 2 - 1, 0, 0)
  win1.box("\u2588", "\u2584", "\u2588")
  win1.setpos(2, 2)
  win1.addstr("0")
  win1.refresh


  inputThread = Thread.new do
    while true 
      win1.keypad = true
      input = win1.getch

      if input == Curses::Key::LEFT then
          win1.addstr("Left key")
      else
          win1.addstr(input.inspect)
      end
      win1.refresh
    end
  end


  snake = [[9, 10], [10, 10], [10, 11], [10, 12], [10, 13], [10, 14]]
  snakeThread = Thread.new do
    while true
      snake.each_with_index do |point, index| 
        c = '*'
        win1.setpos(point[0], point[1])
        win1.addstr(c)
        win1.refresh
        sleep 0.05
      end
      new_head = [snake[0][0]-1, snake[0][1]]
      snake = snake.unshift(new_head)
      snake.pop  

      # collision detection!
      # 32 is ' '
      # 42 is '*'
      # 48 is '0'
      # ascii conversion chart: https://bournetocode.com/projects/GCSE_Computing_Fundamentals/pages/img/ascii_table_lge.png
      # use constants for these ascii codes, more readable, better documentation
      win1.setpos(new_head[0], new_head[1])
      tester = win1.inch()
      if tester != 32
        win1.close 
        raise ' we broke it '
      end

      win1.setpos(win1.cury, win1.curx-1)
      win1.addstr(' ')
    end
  end

  inputThread.join
  snakeThread.join
  sleep 5
rescue => ex
  Curses.close_screen
end