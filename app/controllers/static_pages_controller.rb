class StaticPagesController < ApplicationController
  def index
  	# @candidates represent every unique person that ever ran for president
  	@nominees = Nominee.select('DISTINCT person_id') # returns all nominees with unique person_id
	@candidates = []
	# ideally this should be replaced by a single join query
	@nominees.each do |nominee|
		person = Person.where(:id => nominee.person_id).first # this will only return 1 result
		@candidates.push(person)
	end

	@parties = Party.all
  end

  def show
  end
end
