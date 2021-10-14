# frozen_string_literal: true

require_relative 'base'
require_relative 'options'

# require Rails.root.join('lib', 'maintenance', 'database')
module Maintenance
  # Convenience functions when operatating on databases
  #
  # pry> ::Maintenance::Database.bootstrap_postgres_extension(name: 'postgres_fdw')
  # pry> ::Maintenance::Database.execute_sql(sql: 'select 1;')
  # pry> ::Maintenance::Database.filtered_descendants
  # pry> ::Maintenance::Database.tabled_descendants
  # pry> ::Maintenance::Database.id_column_names_for(model: User)
  # pry> ::Maintenance::Database.indexed_column_names_for(model: User)
  # pry> ::Maintenance::Database.relation_for(model: ::User, sql: 'select id from users limit 2;'
  #      )
  class Database < Base
    class << self
      def db_connection(model: ActiveRecord::Base)
        @db_connection ||= model.connection
      end

      def tabled_descendants(exclude_gem_tables: true)
        ::Maintenance::Base.eager_load_namespaces
        tables = ActiveRecord::Base.descendants.select(&:table_name)
        tables -= tables_of_aggregation if exclude_gem_tables
        tables
      end

      # models with tables, that are not tables_of_aggregation e.g. versions, tags
      # likely the most frequently used function
      def filtered_descendants
        tabled_descendants.reject do |model|
          exclude_tables.include?(model.table_name.to_sym)
        end
      end

      # indexed columns that follow foreign-key "_id" convention
      def indexed_column_names_for(model:)
        Set.new(
          db_connection.indexes(model.table_name).select do |idx|
            Array(idx.columns).all? { |col| col.match?(/_id$/) }
          end.flat_map(&:columns)
        )
      end

      # columns that follow foreign-key "_id" convention
      def id_column_names_for(model:)
        Set.new(
          db_connection.columns(model.table_name).select do |column|
            column.name.match?(/_(?:uu)?id$/)
          end.map(&:name)
        )
      end

      # not a constant as it should be modifiable for exploration
      def exclude_tables
        tables_of_aggregation.map(&:table_name)
      end

      # sql: finds "suspect" records, should exclusively yield ids to be sent to model
      # model: class used to yield a relation of ids found by sql
      #
      # NOTE: limits to 2_147_483_648 IDs... at which point SQL logging is
      #       flooding beyond reason
      def relation_for(model:, sql:)
        suspects = db_connection.execute(sql)
        relation = model.send(:where, id: suspects.flat_map(&:values))
        if relation.to_sql.size > 2_147_483_648
          msg = "too many #{model.name} records found"
          raise ActiveRecord::ActiveRecordError, msg
        end
        suspects.clear
        relation
      end

      # handy to just inject an extension
      def bootstrap_postgres_extension(name:, schema: nil, comment: nil)
        extension_sql = "CREATE EXTENSION IF NOT EXISTS #{name}"
        extension_sql += " WITH SCHEMA #{schema}" if schema
        execute_sql(sql: extension_sql)

        connection ||= ActiveRecord::Base.connection
        safe_comment = connection.quote(comment)
        safe_comment_sql = "COMMENT ON EXTENSION #{name} IS #{safe_comment};"
        execute_sql(sql: safe_comment_sql, connection: connection)
      end

      # just execute some SQL via some connection pool
      def execute_sql(sql:, connection: nil)
        connection ||= ActiveRecord::Base.connection

        results = connection.execute("#{sql};".sub(/;+$/, ';'))
        err_msg = results.result_error_message
        raise err_msg if err_msg.present?

        results
      end

      # run some SQL and yield a maximum of 2_147_483_648 rows as an
      # ActiveRecord::Relation via the given models connection pool
      def execute_sql_on(**kwargs)
        relation_for(**kwargs)
      end

      # faster than bouncing database schemas
      def truncate_all
        filtered_descendants.each do |klass|
          table_name = klass.table_name
          ::Rails.logger.error { "TRUNCATE TABLE #{table_name} CASCADE;" }
          klass.connection.execute("TRUNCATE TABLE #{table_name} CASCADE;")
        rescue ActiveRecord::StatementInvalid => e
          ::Rails.logger.error { e }
        end
      end

      # all ActiveRecord descendants in which a table exists in a storage pool
      def all_tabled_descendants
        ::Rails.configuration.eager_load_namespaces.each(&:eager_load!)
        ActiveRecord::Base.descendants.select(&:table_exists?)
      end

      # filtered ActiveRecord descendants
      #
      # ActiveRecord::Base descendants excluding those from gems and those
      # without storage tables
      def tabled_descendants
        all_tabled_descendants.reject do |model|
          exclude_tables.include?(model.table_name.to_sym)
        end
      end
    end
  end
end
