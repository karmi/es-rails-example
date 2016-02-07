class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.datetime :date_joined
      t.string :display_name
      t.string :url
      t.string :location
      t.text :description
      t.integer :views
      t.integer :votes_up
      t.integer :votes_down
      t.integer :age

      t.timestamps null: false
    end
  end
end
