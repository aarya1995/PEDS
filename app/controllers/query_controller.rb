class QueryController < ApplicationController
  def election_year
  	@year = params[:year]
  end

  def presidential_candidates
  	@person_id = params[:candidate]
  	@candidate = Person.where(id: @person_id).first
  end
	
  # this method doesn't require any params
  def reelected_non_contiguous
  end
	
  # this method doesn't require any params
  def swing_candidates

  end

  def party_history
  	party_id = params[:party]
  	@party = Party.where(id: party_id).first
  end
end
