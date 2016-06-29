require_relative 'lib/es_export'
require 'zlib'
require 'aws-sdk'
require 'json'

$stdout.sync = true

# download file from s3
puts "Downloading file from S3 at s3://#{ENV["S3_BUCKET"]}/#{ENV["S3_KEY"]} ..."
filename = '/tmp/output.gz'
client = Aws::S3::Client.new
client.get_object bucket: ENV["S3_BUCKET"], key: ENV["S3_KEY"], response_target: filename

Zlib::GzipReader.open(filename) do |f|
  # the first line contains metadata about the index
  metadata = JSON.parse(f.readline)

  import = EsExport::Index.new(ENV["ES_INDEX"], url: ENV["ES_URL"])
  import.setting = metadata['settings'][ENV['ES_INDEX']]['settings']
  import.mapping = metadata['mapping'][ENV['ES_INDEX']]['mappings']
  
  if import.exists? && ENV['ES_INDEX_DELETE'] == 'true'
    # delete the existing index

    puts "Deleting existing index ..."
    import.delete
  end

  # create new index
  puts "Creating index named: #{import.name} ..."
  import.create
  
  # setup an array to use for bulk data inserts
  docs = []

  # the rest of the lines are individual docs
  puts "Importing data ..."
  f.each_line do |line|
    data = JSON.parse(line)
    docs << {index: {_index: import.name, _type: data['_type'], _id: data['_id'], data: data['_source']}}

    if docs.length == 100
      import.bulk(docs)
      docs = []
    end
  end

  import.bulk docs if docs.length > 0

  # flush the index to make sure docs were committed, before we ask for the count
  import.flush

  puts "Imported #{import.count} items."
end

puts "Done."
