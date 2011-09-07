ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.string :first_name
    t.string :last_name
    t.string :permalink
    t.boolean :administrator
  end  
end