require_relative "lib/es_export"
require 'zlib'
require 'aws-sdk'

filename = '/tmp/output.gz'
output = Zlib::GzipWriter.open(filename)

export = EsExport::Index.new(ENV["ES_INDEX"], url: ENV["ES_URL"])
export.backup output

output.close

client = Aws::S3::Client.new
client.put_object acl: 'private', body: File.open(filename, 'r'), bucket: ENV["S3_BUCKET"], key: ENV["S3_KEY"]
