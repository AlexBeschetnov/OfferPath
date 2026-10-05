class CreateJobApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :job_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company, null: false
      t.string :position, null: false
      t.string :posting_url
      t.integer :salary_from
      t.integer :salary_to
      t.string :status, null: false, default: "wishlist"
      t.date :applied_on
      t.datetime :status_changed_at
      t.string :next_step
      t.date :next_step_on
      t.text :notes
      t.timestamps
    end

    add_index :job_applications, %i[user_id status]
  end
end
