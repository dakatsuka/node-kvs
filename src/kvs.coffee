net = require('net')

class KVHash
  constructor: ->
    @hash = {}

  get: (key, callback) ->
    callback @hash[key]

  set: (key, value, callback) ->
    @hash[key] = value
    callback()

  unset: (key, callback) ->
    delete @hash[key]
    callback()


class KVServer
  constructor: (@host, @port) ->
    @hash = new KVHash

  run: ->
    server = net.createServer (socket) =>
      socket.setEncoding('utf8')

      socket.on 'data', (data) =>
        requests = data.replace(/\r/g, "").split("\n")
        requests.pop()

        for request in requests
          do (request) =>
            request = request.split(" ")
            command = request[0].toLowerCase()

            switch command
              when 'get'
                @hash.get request[1], (value) ->
                  if value
                    socket.write "+OK\n#{value}\n"
                  else
                    socket.write "+EMPTY\n"

              when 'set'
                @hash.set request[1], request[2], ->
                  socket.write "+OK\n"

              when 'unset'
                @hash.unset request[1], ->
                  socket.write "+OK\n"

              when 'quit'
                socket.end()

              when ''

              else
                socket.write "-ERROR unkown command '#{command}'\n"

    server.listen @port, @host


kvs = new KVServer '0.0.0.0', '3000'
kvs.run()

process.on 'uncaughtException', (err) ->
  console.log "Uncaught exception: #{err} #{err.stack}"
