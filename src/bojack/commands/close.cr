require "./command"

module BoJack
  module Commands
    class CloseSignal < BoJack::Exceptions::Fatal; end

    class Close < BoJack::Commands::Command
      def validate; end

      def perform(socket, memory, params)
        raise BoJack::Commands::CloseSignal.new("closing...")
      end
    end
  end
end
