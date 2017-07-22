require_relative 'string_colors'
require 'pp'


class Map
  def initialize()
    @map = []
    @tile_types = {
      :stone => '#',
      :floor => '.',
      :water => '~',
      :tree => '^',
      :secret => 'x',
    }
    @tile_colors = {
      '#' => '#8F8F8F',
      '.' => '#634F3F',
      '~' => '#4444AA',
      '^' => '#44AA44',
      'x' => '#AA4444',
    }
    @tiles =
      [
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],
       @tile_types[:stone],

       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],
       @tile_types[:floor],

       @tile_types[:water],
       @tile_types[:water],
       @tile_types[:water],
       @tile_types[:water],
       @tile_types[:water],
       @tile_types[:water],

       @tile_types[:tree],
       @tile_types[:tree],
       @tile_types[:tree],
       @tile_types[:tree],
       @tile_types[:tree],
       @tile_types[:tree],
       @tile_types[:tree],
       @tile_types[:tree],

       @tile_types[:secret],
      ]
    @width = 10 * 8
    @height = 10 * 5
  end

  def generate()
    row = []
    @height.times do
      row = []
      @width.times do
        row.push(@tiles.sample())
      end
      @map.push(row)
    end
    smoothen()

    # Draw rivers.
    directions =
      [
       'north',
       'north-east',
       'east',
       'south-east',
       'south',
       'south-west',
       'west',
       'north-west',
      ]
    river_lengths = [10, 20, 30, 40, 50, 60, 70, 80, 90]
    river_x_positions =
      [@width / 2, @width / 3, @width & 4, @width / 5]
    river_y_positions =
      [@height / 2, @height / 3, @height & 4, @height / 5]
    [1, 2, 3, 4].sample.times do
      draw_river(river_x_positions.sample(), river_y_positions.sample(),
                 directions.sample(), river_lengths.sample())
    end

    # Draw lines.
    (0..10).to_a.sample.times do
      draw_line('m', (0..@width).to_a.sample(), (0..@height).to_a.sample(),
                (0..@width).to_a.sample(), (0..@height).to_a.sample(),)
    end

    line_points =
      [
       [0, 30],
       [10, 20],
       [40, 20],
       [50, 40],
       [60, 40],
       [62, 20],
      ]
    draw_polyline('k', line_points)

    # Generate level boundaries.
    generate_level_boundaries()
  end

  # Get all the neighbors for a coordinate in the map.
  #
  # x - X coordinate.
  # x - Y coordinate.
  #
  # Returns an Array of neighbors.
  def neighbors(x, y)
    neighbors = []
    if x != nil && y != nil
      coordinates =
        [
         [x, y - 1],
         [x + 1, y - 1],

         [x + 1, y],

         [x + 1, y + 1],

         [x, y + 1],
         [x - 1, y + 1],
         [x - 1, y],

         [x - 1, y - 1],
        ]
      coordinates.reverse().each do |c|
        begin
          neighbors.push(@map[c[0]][c[1]])
        rescue
          # Ignore it.
        end
      end
    end
    neighbors
  end

  def draw_line(char, x0, y0, x1, y1)
    steep = (y1-y0).abs > (x1-x0).abs
    if steep
      x0,y0 = y0,x0
      x1,y1 = y1,x1
    end
    if x0 > x1
      x0,x1 = x1,x0
      y0,y1 = y1,y0
    end
    deltax = x1-x0
    deltay = (y1-y0).abs
    error = (deltax / 2).to_i
    y = y0
    ystep = nil
    if y0 < y1
      ystep = 1
    else
      ystep = -1
    end
    for x in x0..x1
      if steep
        if (x >= 0 && x < @height) && (y >= 0 && y < @width)
          @map[x][y] = char
        end
      else
        if (x >= 0 && x < @width) && (y >= 0 && y < @height)
          @map[y][x] = char
        end
      end
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end
  end

  def draw_polyline(char, points)
    points.each_with_index do |p, i|
      begin
        draw_line(char, p[0], p[1], points[i + 1][0], points[i + 1][1])
      rescue
        # Ignore it.
      end
    end
  end

  def draw_river(x, y, direction, length)
    length -= 1
    if direction == 'north'
      x = [x - 1, x, x + 1].sample()
      y = y - 1
    elsif direction == 'north-east'
      x = x + 1
      y = [y - 1, y].sample()
    elsif direction == 'east'
      x = x + 1
      y = [y - 1, y, y + 1].sample()
    elsif direction == 'south-east'
      x = x + 1
      y = [y, y + 1].sample()
    elsif direction == 'south'
      x = [x - 1, x, x + 1].sample()
      y = y + 1
    elsif direction == 'south-west'
      x = [x - 1, x].sample()
      y = y + 1
    elsif direction == 'west'
      x = x - 1
      y = [y - 1, y, y + 1].sample()
    elsif direction == 'north-west'
      x = x - 1
      y = [y - 1, y].sample()
    end

    begin
      if (x > 0 && x < @width) && (y > 0 && y < @height)
        @map[y][x] = @tile_types[:water]
      end
    rescue Exception => e
      puts(e)
      # Ignore it.
    end

    if length > 0
      draw_river(x, y, direction, length)
    end
  end

  def generate_level_boundaries()
    @height.times do |y|
      # Create the actual boundaries.
      @map[y][0] = @tile_types[:stone]
      @map[y][@width - 1] = @tile_types[:stone]
      # Make the edges fuzzy.
      fuzzyness = [true, true, false]
      if fuzzyness.sample()
        @map[y][1] = @tile_types[:stone]
      end
      if fuzzyness.sample()
        @map[y][@width - 2] = @tile_types[:stone]
      end
    end
    @width.times do |x|
      # Create the actual boundaries.
      @map[0][x] = @tile_types[:stone]
      @map[@height - 1][x] = @tile_types[:stone]
      # Make the edges fuzzy.
      fuzzyness = [true, true, false]
      if fuzzyness.sample()
        @map[1][x] = @tile_types[:stone]
      end
      if fuzzyness.sample()
        @map[@height - 2][x] = @tile_types[:stone]
      end
    end
  end

  def smoothen()
    # Walls + floors
    @width.times do |y|
      @height.times do |x|
        neighbors = neighbors(x, y)
        begin
          if neighbors.count(@tile_types[:stone]) < 3
            @map[x][y] = '.'
          elsif neighbors.count(@tile_types[:stone]) > 3
            @map[x][y] = '#'
          end
        rescue
          # Ignore it.
        end
      end
    end

    # Secrets
    @height.times do |x|
      @width.times do |y|
        neighbors = neighbors(x, y)
        begin
          if neighbors.count(@tile_types[:secret]) >= 1
            @map[x][y] = 'o'
          end
        rescue
          # Ignore it.
        end
      end
    end

    # Trees
    @height.times do |x|
      @width.times do |y|
        neighbors = neighbors(x, y)
        begin
          if neighbors[0,4].count(@tile_types[:tree]) > 0
            @map[x - 3][y - 1] = @tile_types[:tree]
          end
        rescue
          # Ignore it.
        end
      end
    end
  end

  def html()
    html = '<html><table style="table-layout: fixed; width: 100%">'
    tile_type = ''
    n = []
    neighbors = ''

    (@height - 1).times do |x|
      html += '<tr>'
      (@width - 1).times do |y|
        tile_type = @map[x][y]
        n = neighbors(x, y)
        neighbors =
          n[0] + n[1] + n[2] + "\\n" +
          n[7] + tile_type + n[3] + "\\n" +
          n[6] + n[5] + n[4]
        html +=
          '<td  style="width: 20px; height: 20px; background-color: ' +
          (@tile_colors[tile_type] || '#FFFFFF') +
          '; cursor: pointer;"' +
          'onClick="alert(\'' +
          neighbors + '\')">'
        html += tile_type
        html += '</td>'
      end
      html += '</tr>'
    end

    html += '</table></html>'
    File.open('index.html', 'w') do |f|
      f.write(html)
    end
  end

  def pp(**options)
    s = ''
    do_colorize = options[:colors] || false
    @map.each do |row|
      row.each do |char|
        s += char
      end
      s += "\n"
    end
    s
    if do_colorize == true
      colors =
        [
         # :black,
         :red,
         :green,
         :yellow,
         :blue,
         :magenta,
         :cyan,
         :white,

         # :bg_black,
         :bg_red,
         :bg_green,
         :bg_yellow,
         :bg_blue,
         :bg_magenta,
         :bg_cyan,
         :bg_white,

         :normal,
         :bold,
         :underline,
         :blink,
         :reverse_video,
        ]
      @tile_types.values.each_with_index do |tile_type, i|
        s.gsub!(/#{Regexp.quote(tile_type)}/, '\0'.send(colors[i]))
      end
    end
    s
  end
end



# Main


def prompt(*args)
  print(*args)
  gets
end

def clear_screen()
  puts("\e[H\e[2J")
end

def run()
  map = Map.new()
  map.generate()
  puts(map.pp(:colors => true))
  # map.html()
end

# begin
#   while true
#     run()

#     puts()
#     prompt('To generate a new map, press ' + '[Return]'.cyan +
#            '. To exit, press ' + '[Ctrl + c]'.red + '. ')
#       .strip()

#     clear_screen()
#     exec('ruby ' + $0)  # Rerun the current script.
#   end
# rescue Exception => e
#   # clear_screen()
#   puts(e)  # DEBUG
#   # Ignore it.
# end

run()
