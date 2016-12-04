class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.string :polling_percentage
      t.string :date_poll_taken

      t.timestamps null: false
    end
  end
end
