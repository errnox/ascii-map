class String
  {
    :black => 30,
    :red => 31,
    :green => 32,
    :yellow => 33,
    :blue => 34,
    :magenta => 35,
    :cyan => 36,
    :white => 37,

    :fg_black => 30,     # Alias for `black'
    :fg_red => 31,       # Alias for `red'
    :fg_green => 32,     # Alias for `green'
    :fg_yellow => 33,    # Alias for `yellow'
    :fg_blue => 34,      # Alias for `blue'
    :fg_magenta => 35,   # Alias for `magenta'
    :fg_cyan => 36,      # Alias for `cyan'
    :fg_white => 37,     # Alias for `white'

    :bg_black => 40,
    :bg_red => 41,
    :bg_green => 42,
    :bg_yellow => 43,
    :bg_blue => 44,
    :bg_magenta => 45,
    :bg_cyan => 46,
    :bg_white => 47,

    :normal => 0,
    :bold => 1,
    :underline => 4,
    :underlined => 4,    # Alias for `underline'
    :blink => 5,
    :blinking => 5,      # Alias for `blink'
    :reverse_video => 5,
  }.each do |color, code|
    define_method(color.to_s) do
      colorize(code)
    end
  end

  def no_colors()
    self.gsub(/\033\[\d+m/, '')
  end

  def colorize(color_code)
    "\033[#{color_code}m#{self}\033[0m"
  end
end
