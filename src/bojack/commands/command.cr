require "../exceptions"

module BoJack
  module Commands
    class MissingRequiredParam < BoJack::Exceptions::Runtime; end

    abstract class Command
      def initialize
        @params = Hash(Symbol, String | Array(String)).new
      end

      def run(socket, memory, params : Hash(Symbol, String | Array(String)))
        @params = params
        validate

        perform(socket, memory, params)
      end

      private abstract def perform(socket, memory, params : Hash(Symbol, String | Array(String))) : String | Array(String)

      private abstract def validate

      private def required(name : Symbol)
        raise BoJack::Commands::MissingRequiredParam.new("param '#{name}' is required but not present") unless @params.has_key?(name)
      end
    end
  end
end
