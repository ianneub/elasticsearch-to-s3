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
  puts "Creating index named: #{ENV["ES_INDEX"]} ..."
  import.create
  
  # the rest of the lines are individual docs
  f.each_line do |line|
    data = JSON.parse(line)
    import.put type: data['_type'], id: data['_id'], data: data['_source']
  end
end

puts "Done."
