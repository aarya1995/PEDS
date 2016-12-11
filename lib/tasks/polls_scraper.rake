desc "scrape poll data"
# polls = { election_year => { nominee => { date => percentage } }  }
# Polls Model: { Nominee Id, Polling Percentage, Date }
# Must trim percent symbols off of percentages
task :get_polls => :environment do
	require 'json'

	polls = {}
	nominees = []
	year = "null"
	poll_date = "null"
	election_json = read_json_file("./lib/tasks/election_table_data.json")

	puts Time.now
	
	count = 0
	File.open("lib/polls.txt").each do |line|
		line = line.to_s
		line.strip!

		if line != "=============="
			if count == 0
				year = line
				polls[year] = {} # represents election_year
			elsif count == 1 # split the nominees
				nominees = line.split(", ")
				nominees.each do |nom|
					nom = nom.strip # removes trailing white space
					polls[year][nom] = {}
				end
			else
				if line.include?("%") == false || line.include?("Actual result") # date polls were taken
					poll_date = line
					poll_date.gsub!("\t", " ")
					# puts line
				else # actual polling percentages
					line.strip!
					percentages = line.split(" ")
					# puts percentages
					count2 = 0
					percentages.each do |poll|
						nom = nominees[count2]
						polls[year][nom][poll_date] = poll
						# puts "#{year} -> #{nom} -> { #{poll_date} -> #{poll} }"
						count2 = count2 + 1
					end
				end
			end
			
			count = count + 1
		else # end of election block marked by this delimiter
			count = 0 # reset the counter
		end
	end
	
	# polls should now contain all polling data
	# puts polls
	
	# polls = { election_year => { nominee => { date => percentage } }  }
	# Polls Model: { Nominee Id, Polling Percentage, Date }
	# populate polls table using the polls hash

	polls.each do |k,v|
		election_year = k
		election_hash = find_election_hash_by_year(election_json, election_year)
		election_id = Election.where(:start_date => election_hash["start_date"], 
			 			:end_date => election_hash["end_date"]).first().id
		v.each do |k2, v2|
			# find nominee by joining election, nominee, and person tables
			names_arr = k2.strip.split(" ") # => ["first_name", "middle_name", "last_name"]
			# first find the correct person
			# puts "#{names_arr}"

			if names_arr.length == 3
				person_id = Person.where(:first_name => names_arr[0], :middle_name => names_arr[1],
							:last_name => names_arr[2]).first.id
			else # missing a middle name
				person_id = Person.where(:first_name => names_arr[0], :middle_name => "",
							:last_name => names_arr[1]).first.id
			end
			
			if person_id.nil? || election_id.nil?
				puts "EXCEPTION!"
				puts election_hash
				puts names_arr
			elsif person_id.nil? == false && election_id.nil? == false
				# puts "person: #{names_arr[0]} #{names_arr[1]} #{names_arr[2]} election: #{election_id}"
				nominee_id = Nominee.where(:person_id => person_id, :election_id => election_id).first.id
				# puts "sucessfully finds nominee"
				# create poll records!
				v2.each do |k3, v3|
					poll_percent = v3.chomp("%")
					# puts "fails when trying to create a poll"
					Poll.create(:nominee_id => nominee_id, :polling_percentage => poll_percent,
						:date_poll_taken => k3)
					# puts "sucessfull created a poll"
				end
			end
			
		end
	end
	

	# election_json = read_json_file("./lib/tasks/election_table_data.json")
	# election_hash = find_election_hash_by_year(election_json, year_string)
	# election_id = 	Election.where(:start_date => election_hash["start_date"], 
			 	#:end_date => election_hash["end_date"]).first().id
	

	# pretty print polls results
	# json = polls.to_json
	# pretty_json = JSON.parse(json)
	# puts ""
	# puts JSON.pretty_generate(pretty_json)
	
	puts ""
	puts Time.now
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
	return nil
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