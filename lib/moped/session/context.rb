module Moped
  class Session

    # @api private
    class Context

      attr_reader :session

      def initialize(session)
        @session = session
      end

      def read_preference
        session.read_preference
      end

      def write_concern
        session.write_concern
      end

      def cluster
        session.cluster
      end

      def login(database, username, password)
        cluster.credentials[database.to_s] = [username, password]
      end

      def logout(database)
        cluster.credentials.delete(database.to_s)
      end

      def query(database, collection, selector, options = {})
        opts = read_preference.query_options(options)
        read_preference.with_node(cluster) do |node|
          node.query(database, collection, selector, opts)
        end
      end

      def command(database, command)
        options = read_preference.query_options({})
        read_preference.with_node(cluster) do |node|
          node.command(database, command, options)
        end
      end

      def insert(database, collection, documents, options = {})
        cluster.with_primary do |node|
          if propagate?
            node.pipeline do
              node.insert(database, collection, documents, options)
              node.command(database, write_concern.operation)
            end
          else
            node.insert(database, collection, documents, options)
          end
        end
      end

      def update(database, collection, selector, change, options = {})
        cluster.with_primary do |node|
          if propagate?
            node.pipeline do
              node.update(database, collection, selector, change, options)
              node.command(database, write_concern.operation)
            end
          else
            node.update(database, collection, selector, change, options)
          end
        end
      end

      def remove(database, collection, selector, options = {})
        cluster.with_primary do |node|
          if propagate?
            node.pipeline do
              node.remove(database, collection, selector, options)
              node.command(database, write_concern.operation)
            end
          else
            node.remove(database, collection, selector, options)
          end
        end
      end

      private

      def propagate?
        write_concern.is_a?(WriteConcern::Propagate)
      end
    end
  end
end
