require 'micro-optparse'
require 'curb'

options = Parser.new do |p|
  p.banner = "Simple script to keep a log of MaxCDN failures."
  p.version = "MaxCDN script 0.0 alpha"
  p.option :url, "URL to curl", default: []
  p.option :file, "Log file", default: "maxcdn.log"
end.process!

exit if options[:url].empty?

datacenter = Curl::Easy.perform("http://108.161.187.32/").body_str.match(/^.+?NetDNA(.+?)</)[1].strip!

options[:url].each do |url|
  puts "Testing MaxCDN response for: #{options[:url]}"
  result = "#{Time.now} :: #{datacenter} :: #{url} :: "
  begin
    request = Curl::Easy.http_head(url)
    result += "#{request.response_code} :: #{request.header_str.tr("\r\n", ' ')}"
  rescue
    result += $!
  end
  puts "Result: #{result}"
  File.open(options[:file], 'a') { |f| f.write(result + "\n") }
end
