class CreatePresidents < ActiveRecord::Migration
  def change
    create_table :presidents do |t|
      t.string :start_date
      t.string :end_date

      t.timestamps null: false
    end
  end
end
