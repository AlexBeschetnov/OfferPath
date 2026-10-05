class CreateStatusChanges < ActiveRecord::Migration[8.0]
  def change
    create_table :status_changes do |t|
      t.references :job_application, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.datetime :created_at, null: false
    end

    add_index :status_changes, :to_status
  end
end
