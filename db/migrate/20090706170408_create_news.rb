class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.string     :title
      t.text       :content
      t.references :author
      t.timestamps
    end

    create_table :news_comments do |t|
      t.text       :content
      t.references :news
      t.references :author
      t.timestamps
    end
  end

  def self.down
    drop_table :news_comments
    drop_table :news
  end
end
