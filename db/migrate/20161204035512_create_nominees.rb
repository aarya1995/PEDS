class CreateNominees < ActiveRecord::Migration
  def change
    create_table :nominees do |t|
      t.string :num_popular_votes
      t.string :num_electoral_votes
      t.string :result

      t.timestamps null: false
    end
  end
end
