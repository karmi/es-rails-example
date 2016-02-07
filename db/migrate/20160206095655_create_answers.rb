class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.datetime :creation_date
      t.datetime :last_activity_date
      t.integer :rating
      t.text :body
      t.references :owner, index: true, foreign_key: true, null: false
      t.references :question, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
