module StackExchange
  class IndexManager
    def self.create_index(options={})
      client     = Question.__elasticsearch__.client
      index_name = Question.index_name

      client.indices.delete index: index_name, ignore: 404 if options[:force]

      settings = {
        number_of_shards: 1,
        number_of_replicas: 0,
        analysis: {
          analyzer: {
            html_strip: {
              filter: [ "standard", "lowercase", "stop", "snowball" ],
              char_filter: [ "html_strip" ],
              type: "custom",
              tokenizer: "standard"
            }
          }
        }
      }

      mappings = {}

      settings.merge! Question.settings.to_hash
      settings.merge! Answer.settings.to_hash

      mappings.merge! Question.mappings.to_hash
      mappings.merge! Answer.mappings.to_hash

      client.indices.create index: index_name,
                            body: {
                              settings: settings.to_hash,
                              mappings: mappings.to_hash }
    end

    def self.import(options={})
      errors = []
      errors += Question.import return: 'errors'
      errors += Answer.import return: 'errors',
                  transform: lambda { |r|
                   {index: {_id: r.id, _parent: r.question_id, data: r.__elasticsearch__.as_indexed_json}}
                  }
      return errors
    end
  end
end
