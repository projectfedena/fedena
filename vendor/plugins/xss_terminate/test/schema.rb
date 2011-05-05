ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :entries, :force => true do |t|
    t.column :title, :string
    t.column :body, :text
    t.column :extended, :text
    t.column :person_id, :integer
    t.column :created_on, :datetime
  end

  create_table :comments, :force => true do |t|
    t.column :person_id, :integer
    t.column :title, :string
    t.column :body, :text
    t.column :created_on, :datetime
  end
  
  create_table :messages, :force => true do |t|
    t.column :person_id, :integer
    t.column :recipient_id, :integer
    t.column :body, :text
  end
  
  create_table :reviews, :force => true do |t|
    t.column :title, :string
    t.column :body, :text
    t.column :extended, :text
    t.column :person_id, :integer
    t.column :created_on, :datetime
  end
  
  create_table :sessions, :force => true do |t|
    t.string :session_id, :null => false
    t.text :data
    t.timestamps
  end
  
  create_table :groups, :force => true do |t|
    t.column :person_id,    :integer
    t.column :title,        :string
    t.column :description,  :string
    t.column :members,      :text
    t.timestamps
  end
  
end
