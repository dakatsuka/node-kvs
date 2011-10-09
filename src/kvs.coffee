net = require('net')


class KVServer
  constructor: (@host, @port) ->
    @hash = {}

  get: (key) ->
    @hash[key]

  set: (key, value) ->
    @hash[key] = value

  run: ->
    server = net.createServer (socket) =>
      socket.setEncoding('utf8')

      socket.on 'data', (data) =>
        command = data.replace(/\r\n?/g,"").split(" ")

        switch command[0]
          when "GET"
            result = @get(command[1])
            socket.write "#{result}\n"

          when "SET"
            @set(command[1], command[2])
            socket.write "#{command[2]}\n"

          when "EXIT"
            socket.end()

    server.listen @port, @host


kvs = new KVServer '0.0.0.0', '3000'
kvs.run()
