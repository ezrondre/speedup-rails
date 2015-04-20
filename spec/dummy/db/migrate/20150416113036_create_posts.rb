class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :subject
      t.text :content
      t.references :author, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
