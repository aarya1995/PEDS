class CreateElections < ActiveRecord::Migration
  def change
    create_table :elections do |t|
      t.string :start_date
      t.string :end_date
      t.string :total_electoral_votes
      t.string :total_popular_votes
      t.string :voter_turnout
      t.string :number_of_states_that_voted

      t.timestamps null: false
    end
  end
end
