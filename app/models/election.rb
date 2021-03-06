class Election < ActiveRecord::Base
	has_many :nominees
	belongs_to :president


	def self.find_landslide
		landslides_elections = []
		winners = Nominee.where(result: "win").to_a
		winners.each{
			|winner|
			election = Election.where(id:winner.election_id).first

			popular_percentage = 100*((winner.num_popular_votes.delete(",").to_f)/(election.total_popular_votes.to_i))
			if(popular_percentage>=60)
				year = election.end_date.split(",")[1].strip
				landslides_elections<< [year,results_by_year(year)]
			end
		}
		return landslides_elections

	end
	def self.top_ten_turnout
	
		sorted_elecs= Election.order(:voter_turnout).to_a
		top_ten ={}
		i=0
		sorted_elecs.each{
			|election|
			if(election.voter_turnout=="" or election.voter_turnout==nil)
				break
			else
				i+=1
			end
		}
		for j in (i-10..i-1)
			top_ten[sorted_elecs[j].end_date.split(",")[1].strip] = sorted_elecs[j].voter_turnout
		end
		return top_ten
	end
	def self.find_non_elected

		results = []
		President.find_each{
			|president|
			if(president.nominee_id == nil )
				p1 = Person.where(id: president.person_id).first
				full_name = ""
				if(p1.middle_name == nil or p1.middle_name.length == 0)

					full_name =  p1.first_name + " "+p1.last_name
				else
					full_name= (p1.first_name + " " +p1.middle_name + " " + p1.last_name)
				end
				results << [full_name,president]
			end
		}
		return results

	end

	def self.find_one_term
		results = []
		included = {}
		President.find_each{
			|president|
			p1 = Person.where(id: president.person_id).first
			full_name = ""
			if(p1.middle_name == nil or p1.middle_name.length == 0)

				full_name =  p1.first_name + " "+p1.last_name
			else
				full_name= (p1.first_name + " " +p1.middle_name + " " + p1.last_name)
			end
			if(included[president.person_id])
				results.delete(full_name)
				
			else
				included[president.person_id] = true
				results<<full_name
			end
		}
		return results
	end
	def self.create_display_nominee(nominee, election)
		p1 = Person.where(id: nominee.person_id).first

		disp_nominee = Display_Nominee.new

		if(p1.middle_name == nil or p1.middle_name.length == 0)

			disp_nominee.full_name =  p1.first_name + " "+p1.last_name
		else
			disp_nominee.full_name= (p1.first_name + " " +p1.middle_name + " " + p1.last_name)
		end

		disp_nominee.party = Party.where(id: nominee.party).first.party_name
		disp_nominee.is_winner = nominee.result =="win"
		disp_nominee.num_elec_votes = nominee.num_electoral_votes
		disp_nominee.year = election.end_date.split(",")[1].strip
		popular_percentage = 100*((nominee.num_popular_votes.delete(",").to_f)/(election.total_popular_votes.to_i))
		pop_perc_s = popular_percentage.to_s
		if(pop_perc_s.length > 3)
			pop_perc_s = pop_perc_s[0..pop_perc_s.index(".")+2]
			disp_nominee.popular_percentage = pop_perc_s+"%"
		end
		disp_nominee.polls= Poll.where(nominee_id: nominee.id ).to_a
		return disp_nominee
	end

	def self.results_by_person_id(person_id)
		return create_display_nominations(Person.where(id: person_id).first)
	end

	def self.results_by_name(full_name)
		names_arr = parse_out_names(full_name)
		person =Person.where(:first_name => names_arr[0], :middle_name => names_arr[1],
	 :last_name => names_arr[2]).first()
		return create_display_nominations(person)
	end
	
	# this method returns a Person id by full_name
	def self.find_person_by_name(full_name)
		name_arr = full_name.split(" ")
		person_id = -1
		if name_arr.length == 2 # no middle name
			person_id = Person.where(:first_name => name_arr[0], :last_name => name_arr[1]).first.id
		elsif name_arr.length == 3
			person_id = Person.where(:first_name => name_arr[0], :middle_name => name_arr[1], 
				:last_name => name_arr[2]).first.id
		end

		return person_id
	end

	def self.create_display_nominations(person)
		nominations = Nominee.where(person_id: person.id).to_a
		disp_nominees = []
		nominations.each{
			|nominee|
			election = Election.where(id:nominee.election_id).first
			disp_nominees << create_display_nominee(nominee,election)
		}
		return disp_nominees
	end
	def self.parse_out_names(full_name)
		name_arr = full_name.split(" ")
		first_name = ""
		middle_name = ""
		last_name = ""
		if name_arr.length ==3 
			first_name = name_arr[0].strip
			middle_name = name_arr[1].strip
			last_name = name_arr[2].strip
		elsif name_arr.length ==2
			first_name = name_arr[0].strip
			last_name = name_arr[1].strip
		else
			raise "Name Parsing Error with name: " + full_name
		end
		return [first_name, middle_name, last_name]
	end

	def self.elected_non_contigous 
		return results_by_name("Grover Cleveland")
	end

	def self.find_swing
		disp_nominees = []
		person_id_to_party_id = {}
		already_added = {}
		Nominee.find_each do
			|nominee|
			
			if(person_id_to_party_id[nominee.person_id]!=nil and  person_id_to_party_id[nominee.person_id] != nominee.party_id)
				
				if(!already_added[nominee.person_id])
					disp_nominees<<create_display_nominations(Person.where(id: nominee.person_id).first)
				end
				already_added[nominee.person_id] = true			
			else
				person_id_to_party_id[nominee.person_id]=nominee.party_id
			end

		end
		return disp_nominees
	end

	def self.party_history(party_name)
		#for each party election_result map the election id to the result
		#if a nominee comes in 
		results_hash = {}

		party_record = Party.where(party_name: party_name).first

		party_details = Display_Party.new
		party_details.name = party_record.party_name
		num_participated= 0
		num_won = 0
		nominees=Nominee.where(party_id: party_record.id).to_a
		nominees.each{
			|nominee|
			if(results_hash[nominee.election_id]==nil)
				num_participated+=1
				party_election_result = Party_Election_Result.new
				party_election_result.year = Election.where(id: nominee.election_id).first.end_date.split(",")[1].strip
				party_election_result.num_electoral_votes = nominee.num_electoral_votes.to_i
				party_election_result.is_winner = nominee.result=="win"

				results_hash[nominee.election_id] = party_election_result
			else
				party_election_result = results_hash[nominee.election_id]
				party_election_result.num_electoral_votes+= nominee.num_electoral_votes.to_i
				if(nominee.result=="win")
					party_election_result.is_winner = true
				end
			end
		}

		results_hash.keys.each{
			|election_id|
			party_details.results_by_year<<results_hash[election_id]
			
			if(results_hash[election_id].is_winner)
				num_won+=1
			end
		}
		party_details.win_rate= ((num_won.to_f/num_participated.to_f)*100).to_s
		if(party_details.win_rate.length > 3)
			party_details.win_rate = party_details.win_rate[0..party_details.win_rate.index(".")+2]
			party_details.win_rate = party_details.win_rate+"%"
		end
		return party_details
		
	end

	def self.results_by_year(year_str)
		found = false
		disp_nominees = []
		Election.find_each do 
			|election|
			
			end_year = election.end_date.split(",")[1].strip
			if(end_year==year_str)
				found = true
				eid= election.id
				nominees_relations = Nominee.where(election_id: eid)
				nominees_relations.find_each do
					|nominee|
					disp_nominee = create_display_nominee(nominee, election)
					disp_nominees << disp_nominee
				end
			end
		end
		
		if(!found)
			return []
		else
			return disp_nominees
		end
	end


	class Display_Party
		def initialize()
			@name=""
			@win_rate = ""
			@results_by_year = []
		end

		attr_accessor :name,  :win_rate, :results_by_year
	end

	class Party_Election_Result

		def initialize()
			@year = ""
			@num_electoral_votes=0
			
			@is_winner = false
		end
		attr_accessor :year, :num_electoral_votes,:is_winner
	end
	class Display_Nominee
		def initialize()
			@full_name= ""
			@party = ""
			@popular_percentage = ""
			@is_winner = false
			@num_elec_votes = 0
			@polls = []
			@year = ""
		end

		attr_accessor :year ,:full_name,:party, :popular_percentage,:is_winner ,:num_elec_votes , :polls 
	end
end
