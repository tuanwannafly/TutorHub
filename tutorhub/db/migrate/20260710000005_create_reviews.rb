class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :booking,   null: false, foreign_key: true, index: { unique: true }
      t.references :reviewer,  null: false, foreign_key: { to_table: :users }
      t.integer    :rating,    null: false
      t.text       :comment
      t.timestamps
    end
  end
end