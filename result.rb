require 'csv'
require_relative './run'

class Result
  def result
    CSV.open('results.csv', 'wb') do |csv|
      csv << [
        'base_path',
        'is_surfaced',
        'rules_say_surface',
        'rules_agree',
        'is_all_non_guidance',
        'collection_is_withdrawn',
        'all_documents_are_withdrawn',
        'title_contains_closed',
        'average_taxons_per_document',
        'collection_title_difference',
        'promotional_fraction',
        'apprenticeship_fraction',
        'number_of_unique_taxons',
        'intro_word_count',
        'min_average_document_difference',
        'guidance_fraction',
        'document_collection_overlap',
        'number_of_documents',
        'number_of_documents_score',
        'score',
      ]

      promotional_fraction = args[1]
      apprentice_fraction = args[2]
      intro_word_count = args[3]
      document_difference = args[4]
      guidance_fraction = args[5]
      document_collection_overlap = args[6]
      number_of_documents = args[7]
      number_of_docs_multiplier = args[8]
      number_of_docs_power = args[9]

      collections.each do |collection|
        runner = Runner.new
        should_surface_collection = runner.should_surface?(collection, args) ? 'TRUE' : 'FALSE'
        score = runner.surfacing_score(collection, args)

        csv << [
          collection[:base_path],
          collection[:is_surfaced],
          should_surface_collection,
          collection[:is_surfaced].downcase == should_surface_collection.downcase,
          collection[:is_all_non_guidance],
          collection[:collection_is_withdrawn],
          collection[:all_documents_are_withdrawn],
          !collection[:title_contains_closed].nil?,
          collection[:average_taxons_per_document],
          collection[:collection_title_difference],
          collection[:promotional_fraction],
          collection[:apprenticeship_fraction],
          collection[:number_of_unique_taxons],
          collection[:intro_word_count],
          collection[:min_average_document_difference],
          collection[:guidance_fraction],
          collection[:document_collection_overlap],
          collection[:number_of_documents],
          runner.number_of_documents_score(collection, args),
          score,
        ]
      end
    end
  end

  def args
    [-0.023008131381007768, 0.43335643062615814, 0.3275499582040565, 449.78791657048316, 0.44658745035892966, 0.9660457942317308, 0.7846152177158598, 3.2314690703579547, 0.2356631721669106, -1.693650292396395].freeze
  end

  def collections
    @collections ||= CSV.read('document_collections.csv', headers: true, header_converters: :symbol)
  end
end

Result.new.result
