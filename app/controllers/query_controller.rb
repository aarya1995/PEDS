class QueryController < ApplicationController
  def election_year
  	@year = params[:year]

  	# contains an array of DisplayNominee objects
    @result = Election.results_by_year(@year)
    puts @result
  end

  def presidential_candidates
  	@person_id = params[:candidate]
  	@candidate = Person.where(id: @person_id).first

	# contains an array of DisplayNominee objects
    @result = Election.results_by_person_id(@person_id)
  end
	
  # this method doesn't require any params
  def reelected_non_contiguous
    @result = Election.elected_non_contigous()
    puts @result
  end
	
  # this method doesn't require any params
  def swing_candidates
    @result = Election.find_swing()
    puts @result
  end

  def party_history
  	party_id = params[:party]
    @party =  Party.where(id: party_id).first
  	party_name = @party.party_name
    @result = Election.party_history(party_name)
    puts @result
  end

  def non_elected
    @result = Election.find_non_elected()
  end


  def landslide
    @result =Election.find_landslide()
  end
  
  def served_one_term
  	@result = Election.find_one_term()
  end

  def greatest_turnout
  	@result = Election.top_ten_turnout()
  	hsh_values = @result.values.reverse
  	sorted_hsh = {}

  	hsh_values.each do |val|
  		k = @result.key(val)
  		sorted_hsh[k] = val
  	end
	
	# return sorted result hash
  	@result = sorted_hsh
  end
end
