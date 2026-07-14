class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :tutor,   null: false, foreign_key: { to_table: :users }
      t.date     :booking_date, null: false
      t.time     :start_time,   null: false
      t.time     :end_time,     null: false
      t.integer  :status, null: false, default: 0
      t.decimal  :total_amount, precision: 8, scale: 2, null: false, default: 0
      t.integer  :lock_version, null: false, default: 0   # ActiveRecord optimistic locking
      t.timestamps
    end

    # Race-proof double-booking prevention at DB level.
    add_index :bookings,
              %i[tutor_id booking_date start_time],
              unique: true,
              name: "idx_bookings_unique_slot"

    add_index :bookings, %i[student_id status]
  end
end