class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.datetime :creation_date
      t.datetime :last_activity_date
      t.integer :rating
      t.text :body
      t.string :tags
      t.string :title
      t.integer :favorite_count
      t.integer :view_count
      t.datetime :last_edit_date
      t.references :accepted_answer, index: true, foreign_key: true
      t.references :last_editor, index: true, foreign_key: true
      t.references :owner, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
