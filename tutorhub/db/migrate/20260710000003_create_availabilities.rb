class CreateAvailabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :availabilities do |t|
      t.references :tutor_profile, null: false, foreign_key: true
      t.integer :day_of_week, null: false  # 0=Sun..6=Sat
      t.time    :start_time, null: false
      t.time    :end_time,   null: false
      t.timestamps
    end
    add_index :availabilities, %i[tutor_profile_id day_of_week], name: "idx_availabilities_on_tutor_and_day"
  end
end