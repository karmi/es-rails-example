module Searchable
  def self.search(options={})
    definition = Elasticsearch::DSL::Search::Search.new do
      query do
        if options[:query].present?
          function_score do
            query do
              bool do
                should do
                  multi_match do
                    query    options[:query]
                    operator 'and'
                    fields   ['tags^10', 'title', 'body']
                  end
                end
                should do
                  has_child \
                    type: 'answer',
                    query: { match: { body: options[:query] } },
                    inner_hits: {
                      size: 1,
                      _source: false,
                      highlight: {
                        fields: { body: { fragment_size: 30 } },
                        pre_tags:  '<em class="highlight">',
                        post_tags: '</em>'
                      }
                    }
                end
              end
            end

            functions << { field_value_factor: { field: 'rating' } }
          end
        else
          match_all
        end
      end

      post_filter do
        bool do
          must { terms tags: options[:tags] } if options[:tags].present?
          if options[:months].present?
            must do
              bool do
                options[:months].each do |month|
                  should { range creation_date: { gte: month, lte: "#{month}||+1M" } }
                end
              end
            end
          end
        end
      end if options[:tags].present? || options[:months].present?

      aggregation :tags do
        f = Elasticsearch::DSL::Search::Filters::Bool.new
        f.must { match_all }

        if options[:months].present?
          f.must do
            bool do
              options[:months].each do |month|
                should { range creation_date: { gte: month, lte: "#{month}||+1M" } }
              end
            end
          end
        end

        filter f.to_hash do
          aggregation :tags do
            terms do
              field :tags
              size 5
            end
          end
        end
      end

      aggregation :months do
        f = Elasticsearch::DSL::Search::Filters::Bool.new
        f.must { match_all }
        f.must { terms tags: options[:tags] } if options[:tags].present?

        filter f.to_hash do
          aggregation :months do
            date_histogram do
              field :creation_date
              interval :month
              min_doc_count 0
            end
          end
        end
      end

      highlight do
        field :title, number_of_fragments: 0
        field :body,  fragment_size: 30
        pre_tags  '<em class="highlight">'
        post_tags '</em>'
      end
    end

    Elasticsearch::Model.search(definition, [Question])
  end
end
