desc "fill election data"


task :fill_database => :environment do
	require 'nokogiri'
	require 'open-uri'
	require 'json'

	nominees_json = read_json_file("./lib/tasks/clean_data.json")
	election_json = read_json_file("./lib/tasks/election_table_data.json")
	create_people(nominees_json)
	compute_total_popular(election_json,nominees_json)
	create_elections(election_json)
	create_parties(nominees_json)
	create_nominees(nominees_json,election_json)
	#create_presidents()
end  

def create_presidents()
	Nominee.all.each do 
		|nominee|
		if(nominee.result=="win")
			President.where(:person_id=>nominee.person_id,:party_id=>nominee.party_id,:nominee_id => nominee_id ).first_or_create
		end
	end
end
def create_parties(nominees_json)
	nominees_json.keys.each{
		|year_string|
		nominees_json[year_string].keys.each{
			|nominee| 
			party= nominees_json[year_string][nominee]["party"].strip.downcase
			if (party.include?("unofficially"))
				party = party.split(" ")[1]
			end
			if party[0].ord == 160
				party = party[1..party.length-1]
			end
			Party.where(:party_name => party).first_or_create()
		}
	}
end
def create_nominees(nominees_json,election_json)
	winners ={}
	nominees_json.keys.each{
		|year_string|
		winners[year_string] = false
		nominees_json[year_string].keys.each{
			|presidential_nominee_full_name| 
			
			names_arr = parse_out_names(presidential_nominee_full_name)
			person_id = Person.where(:first_name => names_arr[0], :middle_name => names_arr[1],
			 				:last_name => names_arr[2]).first()
			if(person_id == nil or person_id==0)
					raise "No person found for nominee w/ name "+ presidential_nominee_full_name 
			end
			election_hash = find_election_hash_by_year(election_json, year_string)
		
			if(election_hash==nil)
				raise "No election json found for nominee json w/ year "+ year_string
			end
			
			 election_id = 	Election.where(:start_date => election_hash["start_date"], 
			 	:end_date => election_hash["end_date"]).first().id
			 if(election_id == nil or election_id ==0)
			 	raise "No election database entry found for nominee w year " +year_string
			 end


			 nom_elec_votes = nominees_json[year_string][presidential_nominee_full_name]["electoral_votes"]
			 nom_pop_votes =  nominees_json[year_string][presidential_nominee_full_name]["popular_votes"]
			 total_elec_votes = election_hash["total_electoral_votes"]
			 result = "loss"
			 if(nom_elec_votes.to_i > (total_elec_votes.to_i / 2) +1)
			 	result = "win"
			 	winners[year_string] = true
			 end
			 if(year_string == "1876" and presidential_nominee_full_name=="Rutherford B. Hayes")
			 	result= "win"
			 	winners[year_string] = true
			 end
			 if(year_string == "1824" and presidential_nominee_full_name=="John Quincy Adams")
			 	result= "win"
			 	winners[year_string] = true
			 end
			 nom_party = nominees_json[year_string][presidential_nominee_full_name]["party"].downcase.strip
			 if(nom_party[0].ord == 160)
			 	nom_party = nom_party[1..nom_party.length]
			 end
			 if (nom_party.include?("unofficially"))
				nom_party = nom_party.split(" ")[1]
			 end
			 nom_party_id = Party.where(:party_name=>nom_party).first
			 Nominee.where(:num_popular_votes => nom_pop_votes, 
			 	:num_electoral_votes =>nom_elec_votes,
			 	:result => result, :person_id => person_id,:election_id => election_id,
			 	 :party_id => nom_party_id).first_or_create()
		#	 puts "year " + year_string +" "+presidential_nominee_full_name +" " +result
		}	
	
	}

	#prints missing election results
	# winners.keys.each{
	# 	|year_key|
	# 	if(!winners[year_key])
	# 		puts year_key
	# 	end
	# }

end

def find_election_hash_by_year(election_json,year_string)
	election_json.each{
		|election_hash|
		end_date = election_hash["end_date"]
		end_year = end_date.split(",")[1].strip
		if(end_year==year_string)
			return election_hash
		end
	}
	retur nil
end
def create_elections(election_json)
	election_json.each{
		|election_hash|
		start_d = election_hash["start_date"]
		end_d = election_hash["end_date"]
		total_elec = election_hash["total_electoral_votes"]
		total_pop = election_hash["total_popular"]
		voter_turn = election_hash["voter_turnout"]
		Election.where(:start_date => start_d, :end_date => end_d, 
			:total_electoral_votes=>total_elec,:total_popular_votes=>total_pop,
			:voter_turnout=>voter_turn).first_or_create()
	}
end
def compute_total_popular(election_json, nominees_json)
	election_json.each do
		|election_hash|
		end_date = election_hash["end_date"]
		end_year = end_date.split(",")[1].strip
		matching_nominee_json = nominees_json[end_year]
		#add the total_popular vote to election has by using the first candidates popular votes and 
		#percentage of popular vote in the matching nominee_json
		if(end_year.to_i > 1820)
			nominee_name= matching_nominee_json.keys[0]
			percent_pop = matching_nominee_json[nominee_name]["percent_popular_votes"]
			num_pop = matching_nominee_json[nominee_name]["popular_votes"]

 			total_popular = (num_pop.strip.delete(',').to_i/ (percent_pop.strip.delete("%").to_f/100)).to_i.to_s
 			election_hash["total_popular"] = total_popular
 		else
 			#fill the corresponding election data with empty total_popular votes
 			election_hash["total_popular"] = nil
 		end
 		
	end

	
end
def create_people(nominees_json) 
	nominees_json.keys.each  do 
		|year_key|
		
			nominees_json[year_key].keys.each do
				|presidential_nominee_full_name|
				create_person(presidential_nominee_full_name)
				vp_name= nominees_json[year_key][presidential_nominee_full_name]["vp"]
				if(vp_name.strip!="" and vp_name.strip!="none")
					create_person(vp_name)
				end
			end

		
	end
end

def parse_out_names(full_name)
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

def create_person(full_name)
	#might have an issue with jr/sr in name

	names_arr = parse_out_names(full_name)
	Person.where(:first_name => names_arr[0], :middle_name => names_arr[1],
	 :last_name => names_arr[2]).first_or_create()
	
	

	#person =Person.find_or_initialize_by(first_name: first_name, middle_name: middle_name, last_name: last_name)
end
def read_json_file(filepath)
	json_string = ""
	File.open(filepath, "r") do |f|
		f.each_line do |line|
			json_string+=line.strip
		end
	end
	return JSON.load(json_string)
end