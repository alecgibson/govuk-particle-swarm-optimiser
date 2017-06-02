class Vector
  def self.random_between(lower_bounds, upper_bounds)
    unless lower_bounds.count == upper_bounds.count
      raise 'Lower and upper bound sizes must match'
    end

    random_vector = lower_bounds.each2(upper_bounds).map do |lower_bound, upper_bound|
      range = upper_bound - lower_bound
      lower_bound + (rand * range)
    end

    Vector.elements(random_vector)
  end
end
