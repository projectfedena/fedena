ActiveRecord::ConnectionAdapters.send(:remove_const, :IndexDefinition)

module ActiveRecord
  class SchemaDumper #:nodoc:
    def indexes(table, stream)
      if (indexes = @connection.indexes(table)).any?
        add_index_statements = indexes.map do |index|
          statment_parts = [ ('add_index ' + index.table.inspect) ]
          statment_parts << index.columns.inspect
          statment_parts << (':name => ' + index.name.inspect)
          statment_parts << ':unique => true' if index.unique
          statment_parts << (':limit => ' + Hash[*index.columns.zip(index.limits).flatten].inspect) if index.limits
          '  ' + statment_parts.join(', ')
        end

        stream.puts add_index_statements.sort.join("\n")
        stream.puts
      end
    end
  end
  
  module ConnectionAdapters # :nodoc:
    class IndexDefinition < Struct.new(:table, :name, :unique, :columns,:limits) #:nodoc:
    end
    
    class MysqlAdapter < AbstractAdapter
      def indexes(table_name, name = nil)#:nodoc:
        indexes = []
        current_index = nil
        result = execute("SHOW KEYS FROM #{quote_table_name(table_name)}", name)
        result.each do |row|
          if current_index != row[2]
            next if row[2] == "PRIMARY" # skip the primary key
            current_index = row[2]
            indexes << IndexDefinition.new(row[0], row[2], row[1] == "0", [], [])
          end

          indexes.last.columns << row[4]
          indexes.last.limits << row[7]
        end
        result.free
        indexes
      end
    end
    
    module SchemaStatements
      def add_index(table_name, column_name, options = {})
        column_names = Array(column_name)
        index_name   = index_name(table_name, :column => column_names)

        if Hash === options # legacy support, since this param was a string
          index_type = options[:unique] ? "UNIQUE" : ""
          index_name = options[:name] || index_name
          if Hash === options[:limit]
            quoted_column_names = column_names.map {|e| (options[:limit][e.to_sym].nil? ? "#{quote_column_name(e)}" : "#{quote_column_name(e)}(#{options[:limit][e.to_sym]})") }.join(", ")
          elsif options[:limit]
            quoted_column_names = column_names.map {|e| "#{quote_column_name(e)}(#{options[:limit]})"}.join(", ")
          end
        else
          index_type = options
        end
        quoted_column_names ||= column_names.map { |e| quote_column_name(e) }.join(", ")
        execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)} ON #{quote_table_name(table_name)} (#{quoted_column_names})"
      end
    end
  end
end