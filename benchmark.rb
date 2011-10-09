require 'benchmark'
require 'socket'

n = 20000
socket = TCPSocket.new("localhost", 3000)

Benchmark.bm do |x|
  x.report("SET") {
    1.upto n do |i|
      socket.write("SET key#{i} hogehoge\n")
    end
  }

  x.report("GET") {
    1.upto n do |i|
      socket.write("GET key#{n}\n")
    end
  }

  x.report("UNSET") {
    1.upto n do |i|
      socket.write("UNSET key#{i}\n")
    end
  }
end

socket.close
