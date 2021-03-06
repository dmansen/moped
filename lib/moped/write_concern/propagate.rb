# encoding: utf-8
module Moped
  module WriteConcern

    # Propagating write concerns piggyback a getlasterror command to any write
    # operation with the necessary options.
    #
    # @since 2.0.0
    class Propagate

      # @!attribute operation
      #   @return [ Hash ] The gle operation.
      attr_reader :operation

      # Get the gle command associated with this write concern.
      #
      # @example Get the gle command.
      #   propagate.command(database)
      #
      # @param [ String ] database The database to execute on.
      #
      # @return [ Protocol::Command ] The gle command.
      #
      # @since 2.0.0
      def command(database)
        Protocol::Command.new(database, operation)
      end

      # Initialize the propagating write concern.
      #
      # @example Instantiate the write concern.
      #   Moped::WriteConcern::Propagate.new(w: 3)
      #
      # @param [ Hash ] operation The operation to execute.
      #
      # @since 2.0.0
      def initialize(options)
        operation = options.is_a?(Hash) ? options : {}
        @operation = { getlasterror: 1 }.merge!(operation)
      end
    end
  end
end
