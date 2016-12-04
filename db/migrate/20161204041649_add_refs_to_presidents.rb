class AddRefsToPresidents < ActiveRecord::Migration
  def change
  	add_reference :presidents, :person, foreign_key: true
  	add_reference :presidents, :election, foreign_key: true
  	add_reference :presidents, :nominee, foreign_key: true
  	add_reference :presidents, :party, foreign_key: true
  end
end
