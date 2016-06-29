require 'elasticsearch'
require 'yajl'

module EsExport
  class IndexAlreadyExists < StandardError; end
  class Index
    attr_accessor :name, :url, :client, :setting, :mapping

    def self.find(search="")
      ENV['ELASTICSEARCH_SERVER'] ||= 'http://localhost:9200'
      client = Elasticsearch::Client.new url: ENV['ELASTICSEARCH_SERVER'], log: false
      client.indices.get_aliases.map{|a,b| self.new a}.delete_if{|a| !a.name.include?(search)}
    end

    def initialize(name, url: nil, log: false)
      self.name = name

      self.url = url.nil? ? ENV['ELASTICSEARCH_SERVER'] ||= 'http://localhost:9200' : url
      
      self.client = Elasticsearch::Client.new url: url, log: log
    end

    def <=>(other)
      @name <=> other.name
    end

    def delete
      client.indices.delete index: name
    end

    def create
      raise IndexAlreadyExists, "Index named: #{name} already exists." if exists?
      
      body = {}
      body[:settings] = setting if setting
      body[:mappings] = mapping if mapping

      client.indices.create index: name, body: body.to_json
    end

    def put(type:, id:, data:)
      client.index index: name, type: type, id: id, body: data
    end

    def bulk(data)
      raise ArgumentError unless data.is_a?(Array)

      client.bulk body: data
    end

    def flush
      client.indices.flush(index: name)
    end
    
    def count
      client.count(index: name)['count']
    end

    def exists?
      client.indices.exists? index: name
    end

    def backup(output, options = Hash.new)
      encoder = Yajl::Encoder.new

      # output index settings
      meta = {}
      meta[:settings] = client.indices.get_settings(index: name)
      meta[:mapping] = client.indices.get_mapping(index: name)
      output.write encoder.encode(meta) + "\n"

      # output es data
      count = 0
      each_doc(options) do |doc, n, total|
        output.write(encoder.encode(doc) + "\n")
        count += 1
      end
      
      count
    end

    def each_doc(options = Hash.new, &block)
      default = {
        size: 1_000,
        query: { match_all: {} },
        sort: '_id',
        fields: ""
      }
      options = default.merge(options)

      body = Hash.new
      body[:query] = options[:query]
      body[:sort] = options[:sort]
      body[:fields] = options[:fields].split(",") unless options[:fields].empty?
      
      result = client.search index: name, scroll: '10m', size: options[:size], search_type: 'scan', body: body
      total = result['hits']['total']
      processed = 0

      # process hits from scroll action until all have been processed
      client.scroll(scroll: '10m', scroll_id: result['_scroll_id'])['hits']['hits'].each do |hit|
        processed += 1
        block.call hit, processed, total if block_given?
      end while processed < total

      true
    end
  end
end
