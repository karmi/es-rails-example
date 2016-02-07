class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.datetime :creation_date
      t.integer :rating
      t.text :text
      t.references :owner, index: true, foreign_key: true, null: false
      t.integer :commentable_id, null: false
      t.string :commentable_type, null: false

      t.timestamps null: false
    end
  end
end
