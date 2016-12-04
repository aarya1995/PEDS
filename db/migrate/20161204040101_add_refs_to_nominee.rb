class AddRefsToNominee < ActiveRecord::Migration
  def change
  	add_reference :nominees, :person, foreign_key: true
  	add_reference :nominees, :election, foreign_key: true
  	add_reference :nominees, :party, foreign_key: true
  end
end
