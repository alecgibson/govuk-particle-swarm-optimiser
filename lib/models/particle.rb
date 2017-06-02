class Particle
  attr_accessor :position
  attr_accessor :best_known_position
  attr_accessor :best_known_value
  attr_accessor :velocity

  def initialize(position:, velocity:)
    @position = position
    @best_known_position = position
    @velocity = velocity
    @best_known_value = Float::INFINITY
  end
end
