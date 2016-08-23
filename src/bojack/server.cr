require "socket"
require "logger"
require "./memory"
require "./command"

module BoJack
  class Server
    @hostname : String
    @port : Int8 | Int16 | Int32 | Int64

    def initialize(@hostname = "127.0.0.1", @port = 5000, @logger = Logger.new(STDOUT))
      @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
        io << "[bojack][#{hostname}:#{port}][#{datetime}][#{severity}] #{message}"
      end
      @memory = BoJack::Memory(String, Array(String)).new
    end

    def start
      server = TCPServer.new(@hostname, @port)
      server.tcp_nodelay = true
      server.recv_buffer_size = 4096

      @logger.info("Server started on #{@hostname}:#{@port}")

      loop do
        if socket = server.accept
          @logger.info("#{socket.remote_address} connected")

          spawn do
            loop do
              begin
                request = socket.gets

                break unless request
                @logger.info("#{socket.remote_address} requested: #{request.strip}")

                response = handle_request(request)
                socket.puts(response)
              rescue e : BoJack::Exceptions::Fatal
                @logger.error(e.message)
                socket.close
                break
              end
            end
          end
        end
      end
    end

    private def handle_request(request : String)
       begin
        params = parse_request(request)
        command = BoJack::Command.from(params[:command])

        response = command.run([0], @memory, params)
        response
      rescue e : BoJack::Exceptions::Runtime
        #response = "error: #{e.message}"
        #@logger.error(response)
      end
    end

    private def parse_request(request) : Hash(Symbol, String | Array(String))
      request = request.split(" ").map { |item| item.strip }

      command = request[0]
      result = Hash(Symbol, String | Array(String)).new
      result[:command] = command

      result[:key] = request[1] if request[1]?
      result[:value] = request[2].split(",") if request[2]?

      result
    end
  end
end
