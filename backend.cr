require "http/server"

port = 8022

counter = 1

server = HTTP::Server.new(port) do |context|
  context.response.content_type = "text/plain"
  context.response.headers["Cache-Control"] = "public"
  context.response.headers["Cache-Control"] = "max-age=31536000"
  #context.response.headers["Expores"] = 
  context.response.print(counter += 1)

  puts "#{context.request.method} #{context.request.path}: 200 counter=#{counter}"
end

puts "Listening on port #{port}..."
server.listen
