class Election < ActiveRecord::Base
	has_many :nominees
	belongs_to :president

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

		popular_percentage = 100*((nominee.num_popular_votes.delete(",").to_f)/(election.total_popular_votes.to_i))
		pop_perc_s = popular_percentage.to_s
		if(pop_perc_s.length > 3)
			pop_perc_s = pop_perc_s[0..pop_perc_s.index(".")+2]
			disp_nominee.popular_percentage = pop_perc_s+"%"
		end
		disp_nominee.polls= Poll.where(nominee_id: nominee.id ).to_a
		return disp_nominee
	end
	def self.results_by_name(full_name)
		names_arr = parse_out_names(full_name)
		person =Person.where(:first_name => names_arr[0], :middle_name => names_arr[1],
	 :last_name => names_arr[2]).first()
		return create_display_nominations(person)
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
	class Display_Nominee
		def initialize()
			@full_name= ""
			@party = ""
			@popular_percentage = ""
			@is_winner = false
			@num_elec_votes = 0
			@polls = []
		end

		attr_accessor :full_name,:party, :popular_percentage,:is_winner ,:num_elec_votes , :polls 
	end
end
