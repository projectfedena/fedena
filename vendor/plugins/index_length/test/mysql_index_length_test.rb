require 'test_helper'

class MysqlIndexLengthTest < ActiveSupport::TestCase
  load_schema  
  
  class Person < ActiveRecord::Base
  end

  def test_schema_has_loaded_correctly
    assert_equal [], Person.all
  end

  def test_ensure_index_created_when_limit_is_an_integer
     Person.connection.add_index("people", ["last_name"], :limit => 10)

     indexes = {}
     Person.connection.execute("show index from people").each_hash do |r|
       if r['Key_name'] != 'PRIMARY'
         indexes[r['Key_name']] = r['Sub_part']
       end
     end

     assert_equal 1, indexes.size
     assert_equal "10", indexes["index_people_on_last_name"]
     Person.connection.remove_index("people", "last_name")
  end
    
  def test_ensure_index_created_when_limit_is_a_hash
     Person.connection.add_index("people", ["last_name"], :limit => {:last_name => 10})

     indexes = {}
     Person.connection.execute("show index from people").each_hash do |r|
       if r['Key_name'] != 'PRIMARY'
         indexes[r['Key_name']] = r['Sub_part']
       end
     end

     assert_equal 1, indexes.size
     assert_equal "10", indexes["index_people_on_last_name"]  
     Person.connection.remove_index("people", "last_name")
  end

  def test_ensure_index_created_2_columns_and_limit_is_a_hash
     Person.connection.add_index("people", [:last_name, :first_name], :limit => {:first_name => 20, :last_name => 10})

     indexes = {}
     Person.connection.execute("show index from people").each_hash do |r|
       if r['Key_name'] != 'PRIMARY'
         indexes[r['Column_name']] = r['Sub_part']
       end
     end

     assert_equal 2, indexes.size
     assert_equal "10", indexes["last_name"]
     assert_equal "20", indexes["first_name"]
     Person.connection.remove_index("people", "last_name_and_first_name")
  end
   
  def test_add_index
    assert_nothing_raised { Person.connection.add_index("people", "last_name") }
    assert_nothing_raised { Person.connection.remove_index("people", "last_name") }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name", "first_name"]) }
    assert_nothing_raised { Person.connection.remove_index("people", :column => ["last_name", "first_name"]) }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name", "first_name"]) }
    assert_nothing_raised { Person.connection.remove_index("people", :name => "index_people_on_last_name_and_first_name") }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name", "first_name"]) }
    assert_nothing_raised { Person.connection.remove_index("people", "last_name_and_first_name") }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name", "first_name"]) }
    assert_nothing_raised { Person.connection.remove_index("people", ["last_name", "first_name"]) }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name"], :limit => 10) }
    assert_nothing_raised { Person.connection.remove_index("people", "last_name") }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name"], :limit => {:last_name => 10}) }
    assert_nothing_raised { Person.connection.remove_index("people", ["last_name"]) }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name", "first_name"], :limit => 10) }
    assert_nothing_raised { Person.connection.remove_index("people", ["last_name", "first_name"]) }
    assert_nothing_raised { Person.connection.add_index("people", ["last_name", "first_name"], :limit => {:last_name => 10, :first_name => 20}) }
    assert_nothing_raised { Person.connection.remove_index("people", ["last_name", "first_name"]) }
  end  
end
