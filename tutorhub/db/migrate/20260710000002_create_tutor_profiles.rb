class CreateTutorProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :tutor_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :subject, null: false
      t.string  :headline
      t.decimal :hourly_rate, precision: 8, scale: 2, null: false, default: 0
      t.text    :bio
      t.timestamps
    end
  end
end
