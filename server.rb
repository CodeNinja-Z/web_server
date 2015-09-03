require 'socket'                                    # Require socket from Ruby Standard Library (stdlib)

host = 'localhost'
port = 2000

server = TCPServer.open(host, port)                 # Socket to listen to defined host and port
puts "Server started on #{host}:#{port} ..."        # Output to stdout that server started

loop do                                             # Server runs forever
  client = server.accept                            # Wait for a client to connect. Accept returns a TCPSocket

  lines = []
                                # It doesn't really chomp at here. Here it is just a check.
  while (line = client.gets) && !line.chomp.empty?  # Read the request and collect it until it's empty. 'gets' gets a single line each time.
    lines << line.chomp # Here it chomp.
  end
  puts lines                                        # Output the full request to stdout

  #client.puts(Time.now.ctime)                       # Output the current time to the client

  # RegEx way to detect a ' ' (space) is either ' ' or '\ '
  filename = lines[0].gsub(/GET \//, '').gsub(/ HTTP.*/, '')  # gsub is global substitution

  if File.exists?(filename)
    response_body = File.read(filename)
    ext = File.extname(filename)
    # keyboard shortcut note: shift + up/down, command + D(cursor must be on a line for this) 
      success_header = []
      success_header << "HTTP/1.1 200 OK"
      if ext == ".html"
        success_header << "Content-Type: text/html" # should reflect the appropriate content type (HTML, CSS, text, etc)
      elsif ext == ".css"
        success_header << "Content-Type: text/css"
      end
      success_header << "Content-Length: #{response_body.length}" # should be the actual size of the response body
      success_header << "Connection: close"
    end
    # \r: end of line, \n: start a new line
    header = success_header.join("\r\n")

  else
    response_body = "File Not Found\n" # need to indicate end of the string with \n

    not_found_header = []
    not_found_header << "HTTP/1.1 404 Not Found"
    not_found_header << "Content-Type: text/plain" # is always text/plain
    not_found_header << "Content-Length: #{response_body.length}" # should the actual size of the response body
    not_found_header << "Connection: close"
    header = not_found_header.join("\r\n")
  end

  response = [header, response_body].join("\r\n\r\n")

  # filename = "index.html"
  # response = File.read(filename)
  client.puts(response)
  # client.puts(response_body)
  puts response
  client.close                                      # Disconnect from the client
end
