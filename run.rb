require_relative 'lib/particle_swarm_optimizer'
require 'csv'
require 'json'

class Runner
  def run
    optimizer = ParticleSwarmOptimizer.new(
      solution_lower_bounds: [-5, 0, 0, 0, 0, 0, 0, 0, -5, -2],
      solution_upper_bounds: [5, 1, 1, 500, 1, 1, 1, 20, 5, 2],
      stability_threshold: 10,
      number_of_particles: 100,
    )

    optimizer.optimize do |args|
      collections.reduce(0) do |score, collection|
        collection_surfaced = should_surface?(collection, args)
        if collection_surfaced == (collection[:is_surfaced].downcase == 'true')
          score -= 1
        end
        score
      end
    end
  end

  def should_surface?(collection, args)
    surfacing_score(collection, args) > args[0]
  end

  def surfacing_score(collection, args)
    return -1 if collection[:is_all_non_guidance].downcase == 'true'
    return -1 if collection[:collection_is_withdrawn].downcase == 'true' && collection[:all_documents_are_withdrawn].downcase == 'false'
    return 1 unless collection[:title_contains_closed].nil?
    vote_result(collection, args)
  end

  # [-0.023008131381007768, 0.43335643062615814, 0.3275499582040565, 449.78791657048316, 0.44658745035892966, 0.9660457942317308, 0.7846152177158598, 3.2314690703579547, 0.2356631721669106, -1.693650292396395]
  def vote_result(collection, args)
    promotional_fraction = args[1]
    apprentice_fraction = args[2]
    intro_word_count = args[3]
    document_difference = args[4]
    guidance_fraction = args[5]
    document_collection_overlap = args[6]
    number_of_documents = args[7]
    number_of_docs_multiplier = args[8]
    number_of_docs_power = args[9]

    score = 0
    score += 1 if collection[:promotional_fraction].to_f > promotional_fraction
    score += 1 if collection[:apprenticeship_fraction].to_f > apprentice_fraction
    score += 1 if collection[:intro_word_count].to_f > intro_word_count
    score += 1 if collection[:min_average_document_difference].to_f < document_difference
    score -= 1 if collection[:guidance_fraction].to_f < guidance_fraction
    score -= 1 if collection[:document_collection_overlap].to_f < document_collection_overlap

    number_of_docs_score = number_of_documents_score(collection, args)

    score += number_of_docs_score

    if score == 0
      number_of_docs_score
    else
      score
    end
  end

  def number_of_documents_score(collection, args)
    number_of_documents = args[7]
    number_of_docs_multiplier = args[8]
    number_of_docs_power = args[9]

    number_of_docs_score = collection[:number_of_documents].to_f > number_of_documents ? 1 : -1
    (number_of_docs_score.to_f * number_of_docs_multiplier.to_f * (number_of_documents.to_f ** number_of_docs_power.to_f)).real
  end

  def collections
    @collections ||= CSV.read('document_collections.csv', headers: true, header_converters: :symbol)
  end
end

Runner.new.run
