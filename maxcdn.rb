require 'micro-optparse'
require 'curb'

options = Parser.new do |p|
  p.banner = "Simple script to keep a log of MaxCDN failures."
  p.version = "MaxCDN script 0.0 alpha"
  p.option :url, "URL to curl", default: "http://www.maxcdn.com"
  p.option :file, "Log file", default: "maxcdn.log"
end.process!

puts "Testing MaxCDN Response for: #{options[:url]}"

datacenter = Curl::Easy.perform("http://108.161.187.32/").body_str.match(/^.+?NetDNA(.+?)</)[1].strip!
request = Curl::Easy.http_head(options[:url])
result = "#{Time.now} :: #{datacenter} :: #{request.response_code} :: #{request.header_str.tr("\r\n", ' ')}"
puts "Result: #{result}"
File.open(options[:file], 'a') { |f| f.write(result) }
