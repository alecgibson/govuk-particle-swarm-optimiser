require_relative 'models/particle'
require 'matrix'
require_relative 'models/vector'

class ParticleSwarmOptimizer
  def initialize(
    solution_lower_bounds:,
    solution_upper_bounds:,
    number_of_particles: 10,
    omega: 1,
    phip: 2,
    phig: 2,
    target_delta: 1e-8,
    stability_threshold: 10,
    max_iterations: 1e3)

    @solution_lower_bounds = Vector.elements(solution_lower_bounds)
    @solution_upper_bounds = Vector.elements(solution_upper_bounds)

    validate_bounds

    @number_of_particles = number_of_particles
    @omega = omega
    @phip = phip
    @phig = phig
    @target_delta = target_delta
    @stability_threshold = stability_threshold
    @max_iterations = max_iterations

    @best_global_position = nil
    @best_global_value = Float::INFINITY
  end

  def optimize(&block)
    particles = initialize_particles

    initialize_best_global_position_and_value(particles, &block)

    consecutive_low_delta_count = 0
    iterations = 0

    while iterations < @max_iterations && consecutive_low_delta_count < @stability_threshold
      iterations += 1
      delta = update_solutions(particles, &block)
      consecutive_low_delta_count = delta < @target_delta ? consecutive_low_delta_count + 1 : 0
      puts "Iteration #{iterations}: #{@best_global_value} (#{delta} delta)"
      puts @best_global_position
    end

    puts '=== FINISHED ==='
  end

private

  def validate_bounds
    @solution_lower_bounds.each2(@solution_upper_bounds) do |lower_bound, upper_bound|
      if upper_bound < lower_bound
        raise "Upper bound #{upper_bound} < Lower bound #{lower_bound}"
      end
    end
  end

  def initialize_particles
    Array.new(@number_of_particles).map do
      starting_position = Vector.random_between(@solution_lower_bounds, @solution_upper_bounds)
      range = @solution_upper_bounds - @solution_lower_bounds
      starting_velocity = Vector.random_between(range * -1.0, range)

      Particle.new(position: starting_position, velocity: starting_velocity)
    end
  end

  def initialize_best_global_position_and_value(particles, &block)
    particles.each do |particle|
      value = block.call(particle.position)

      if value < @best_global_value
        @best_global_value = value
        @best_global_position = particle.position
      end
    end
  end

  def update_solutions(particles, &block)
    best_global_value_at_start_of_iteration = @best_global_value

    particles.each do |particle|
      update_particle_velocity!(particle)
      update_particle_position!(particle)

      value = block.call(particle.position)

      update_best_known_values!(particle, value)
    end

    (@best_global_value - best_global_value_at_start_of_iteration).abs
  end

  def update_particle_velocity!(particle)
    rp = rand
    rg = rand
    new_velocity = particle.velocity.each_with_index.map do |_, index|
      @omega * particle.velocity[index]
      + @phip * rp * (particle.best_known_position[index] - particle.position[index])
      + @phig * rg * (@best_global_position[index] - particle.position[index])
    end

    particle.velocity = Vector.elements(new_velocity)
  end

  def update_particle_position!(particle)
    particle.position = particle.position + particle.velocity
  end

  def update_best_known_values!(particle, value)
    if value < particle.best_known_value
      particle.best_known_value = value
      particle.best_known_position = particle.position

      if value < @best_global_value
        @best_global_value = value
        @best_global_position = particle.position
      end
    end
  end
end
