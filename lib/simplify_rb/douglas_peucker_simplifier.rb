# Optimized Douglas-Peucker algorithm

module SimplifyRb
  class DouglasPeuckerSimplifier
    INITIAL_STACK_SIZE = 1024

    def initialize
      @stack = Array.new(INITIAL_STACK_SIZE) { [0, 0] }
      @stack_size = 0
    end

    def process(points, sq_tolerance)
      return points if points.length <= 2

      @markers = Array.new(points.length, false)
      @markers[0] = true
      @markers[-1] = true

      simplify_douglas_peucker(points, sq_tolerance)

      result = []
      points.each_with_index do |point, i|
        result << point if @markers[i]
      end
      result
    end

    private

    def simplify_douglas_peucker(points, sq_tolerance)
      @stack_size = 1
      @stack[0] = [0, points.length - 1]

      max_sq_dist = 0.0
      temp_dist = 0.0

      while @stack_size > 0
        @stack_size -= 1
        first_i, last_i = @stack[@stack_size]
        max_sq_dist = 0.0
        index = nil

        p1 = points[first_i]
        p2 = points[last_i]

        dx = p2.x - p1.x
        dy = p2.y - p1.y
        sq_length = dx * dx + dy * dy

        i = first_i + 1
        while i < last_i
          temp_dist = sq_dist_point_to_segment(points[i], p1, p2, dx, dy, sq_length)
          if temp_dist > max_sq_dist
            index = i
            max_sq_dist = temp_dist
          end
          i += 1
        end

        if max_sq_dist > sq_tolerance
          @markers[index] = true

          ensure_stack_capacity(2)
          @stack[@stack_size] = [first_i, index]
          @stack_size += 1
          @stack[@stack_size] = [index, last_i]
          @stack_size += 1
        end
      end

      points
    end

    def ensure_stack_capacity(additional_size)
      if @stack_size + additional_size > @stack.length
        new_size = [@stack.length * 2, @stack_size + additional_size].max
        @stack.concat(Array.new(new_size - @stack.length) { [0, 0] })
      end
    end

    def sq_dist_point_to_segment(point, p1, p2, dx, dy, sq_length)
      if sq_length.zero?
        pdx = point.x - p1.x
        pdy = point.y - p1.y
        return pdx * pdx + pdy * pdy
      end

      t = ((point.x - p1.x) * dx + (point.y - p1.y) * dy) / sq_length
      t = t > 1 ? 1 : (t < 0 ? 0 : t)

      px = p1.x + (t * dx)
      py = p1.y + (t * dy)

      pdx = point.x - px
      pdy = point.y - py
      pdx * pdx + pdy * pdy
    end
  end
end
