class AddNomineeRefToPolls < ActiveRecord::Migration
  def change
  	add_reference :polls, :nominee, foreign_key: true
  end
end
