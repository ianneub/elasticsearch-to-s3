require 'elasticsearch'

client = Elasticsearch::Client.new url: ENV['ES_URL'], log: false
1.upto(100).each do |n|
  client.index index: ENV['ES_INDEX'], type: 'testing', id: "#{n}", body: {
    title: "Testing #{n}",
    notes: "This is only a test of iteration #{n}",
    asdf: n
  }
end

puts "Done"
