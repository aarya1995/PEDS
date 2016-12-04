class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :birth_date
      t.string :date_of_death

      t.timestamps null: false
    end
  end
end
