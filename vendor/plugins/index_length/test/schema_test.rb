require 'test_helper'

class SchemaTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
      alias_method :execute_without_stub, :execute
      def execute(sql, name = nil) return sql end
    end
  end

  def teardown
    ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
      remove_method :execute
      alias_method :execute, :execute_without_stub
    end
  end

  def test_add_index
    assert_equal "CREATE  INDEX `index_people_on_last_name` ON `people` (`last_name`)", ActiveRecord::Base.connection.add_index(:people, :last_name)
    assert_equal "CREATE  INDEX `index_people_on_last_name` ON `people` (`last_name`(10))", ActiveRecord::Base.connection.add_index(:people, :last_name, :limit => 10)
    assert_equal "CREATE  INDEX `index_people_on_last_name_and_first_name` ON `people` (`last_name`(15), `first_name`(15))", ActiveRecord::Base.connection.add_index(:people, [:last_name, :first_name], :limit => 15)
    assert_equal "CREATE  INDEX `index_people_on_last_name_and_first_name` ON `people` (`last_name`(15), `first_name`)", ActiveRecord::Base.connection.add_index(:people, [:last_name, :first_name], :limit => {:last_name => 15})
    assert_equal "CREATE  INDEX `index_people_on_last_name_and_first_name` ON `people` (`last_name`(15), `first_name`(10))", ActiveRecord::Base.connection.add_index(:people, [:last_name, :first_name], :limit => {:last_name => 15, :first_name => 10})
  end
end