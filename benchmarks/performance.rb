require "benchmark"
require "socket"

n = 5_000
socket = TCPSocket.open("127.0.0.1", 5000)
socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

Benchmark.bmbm do |x|
  x.report("shared-connection-get") do
    threads = []
    n.times do |i|
      threads[i] = Thread.new do
        socket.puts("increment a\n")
        socket.gets
      end

      threads.map(&:join)
    end
  end

  socket.close
end
