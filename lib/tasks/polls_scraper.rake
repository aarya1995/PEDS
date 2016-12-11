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

	# populate polls table using the polls hash
	

	# pretty print polls results
	json = polls.to_json
	pretty_json = JSON.parse(json)
	puts ""
	puts JSON.pretty_generate(pretty_json)
	
	puts ""
	puts Time.now
end