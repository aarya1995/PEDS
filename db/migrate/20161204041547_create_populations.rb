class CreatePopulations < ActiveRecord::Migration
  def change
    create_table :populations do |t|
      t.string :year
      t.string :us_population
      t.string :growth_percent
      t.string :annual_change
      t.string :data_note
      t.string :source_link

      t.timestamps null: false
    end
  end
end
