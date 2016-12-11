# .elections_states:nth-child(1) tr:nth-child(6) td:nth-child(2)
# 1824 is the last election with available popular vote data on ucsb
# 1800 and older elections only returning second nominee
# also no vp for 1800 and older elections and no popular votes either

desc "scrape election data"

task :grab_nominee_data => :environment do
	require 'nokogiri'
	require 'open-uri'
	require 'json'


	url = "http://www.presidency.ucsb.edu/showelection.php?year=1936"
	doc = Nokogiri::HTML(open(url))
	# start benchmark
	puts Time.now

	# scrape election links from main page #

	home_url = "http://www.presidency.ucsb.edu/elections.php"
	doc2 = Nokogiri::HTML(open(home_url))

	# puts doc2.at_css("title").text
	# puts ""

	election_links = doc2.css(".docpres a")
	election_arr = []

	election_links.each do |link|
		election_link = link.attr('href').to_s
		full_link = "http://www.presidency.ucsb.edu/" + election_link
		election_arr.push(full_link)
	end

	# end scraping of links #

	elections = {}
	
	election_arr.each do |url|
		doc = Nokogiri::HTML(open(url))

		yr_string = doc.at_css("title").text.to_s
		election_year = yr_string[0..3].to_i
		count = 0
		nominees = {}
		elections[yr_string] = {}

		if election_year > 1924 && election_year != 1936 # works with all elections after 1924, except 1936

			table_elements = doc.css(".elections_states:nth-child(1) tr")

			# remove first two rows
			table_elements.shift
			table_elements.shift

			table_elements.each do |election_row|
			
				party = election_row.css("td:nth-child(2)").text.to_s
				presidential_candidate = election_row.css("td:nth-child(4)").text.to_s
				vice_presidential_candidate = election_row.css("td:nth-child(5)").text.to_s
				num_electoral_votes = election_row.css("td:nth-child(6)").text.to_s
				percent_electoral_votes = election_row.css("td:nth-child(7)").text.to_s
				popular_votes = election_row.css("td:nth-child(8)").text.to_s
				percent_popular_votes = election_row.css("td:nth-child(9)").text.to_s

				nominees[presidential_candidate] = {}
				nominees[presidential_candidate]["party"] = party
				nominees[presidential_candidate]["vp"] = vice_presidential_candidate
				nominees[presidential_candidate]["electoral_votes"] = num_electoral_votes
				nominees[presidential_candidate]["percent_electoral_votes"] = percent_electoral_votes
				nominees[presidential_candidate]["popular_votes"] = popular_votes
				nominees[presidential_candidate]["percent_popular_votes"] = percent_popular_votes	
			end

		elsif election_year == 1936 # handle this case separately
			table_elements = doc.css(".elections_states:nth-child(2) tr")

			# remove first two rows
			table_elements.shift
			table_elements.shift

			table_elements.each do |election_row|

				party = election_row.css("td:nth-child(2)").text.to_s
				presidential_candidate = election_row.css("td:nth-child(4)").text.to_s
				vice_presidential_candidate = election_row.css("td:nth-child(5)").text.to_s
				num_electoral_votes = election_row.css("td:nth-child(6)").text.to_s
				percent_electoral_votes = election_row.css("td:nth-child(7)").text.to_s
				popular_votes = election_row.css("td:nth-child(8)").text.to_s
				percent_popular_votes = election_row.css("td:nth-child(9)").text.to_s

				nominees[presidential_candidate] = {}
				nominees[presidential_candidate]["party"] = party
				nominees[presidential_candidate]["vp"] = vice_presidential_candidate
				nominees[presidential_candidate]["electoral_votes"] = num_electoral_votes
				nominees[presidential_candidate]["percent_electoral_votes"] = percent_electoral_votes
				nominees[presidential_candidate]["popular_votes"] = popular_votes
				nominees[presidential_candidate]["percent_popular_votes"] = percent_popular_votes
			end
		elsif election_year <= 1924 && election_year > 1800 # works with elections 1924 and older (but greater than 1800)

			table_elements = doc.css(".elections_states:nth-child(2) tr")

			# remove first two rows
			table_elements.shift
			table_elements.shift

			table_elements.each do |election_row|

				party = election_row.css("td:nth-child(2)").text.to_s
				presidential_candidate = election_row.css("td:nth-child(4)").text.to_s
				vice_presidential_candidate = election_row.css("td:nth-child(5)").text.to_s
				num_electoral_votes = election_row.css("td:nth-child(6)").text.to_s
				percent_electoral_votes = election_row.css("td:nth-child(7)").text.to_s
				popular_votes = election_row.css("td:nth-child(8)").text.to_s
				percent_popular_votes = election_row.css("td:nth-child(9)").text.to_s

				nominees[presidential_candidate] = {}
				nominees[presidential_candidate]["party"] = party
				nominees[presidential_candidate]["vp"] = vice_presidential_candidate
				nominees[presidential_candidate]["electoral_votes"] = num_electoral_votes
				nominees[presidential_candidate]["percent_electoral_votes"] = percent_electoral_votes
				nominees[presidential_candidate]["popular_votes"] = popular_votes
				nominees[presidential_candidate]["percent_popular_votes"] = percent_popular_votes
			end

		elsif election_year <= 1800 # year 1800 and older elections

				table_elements = doc.css(".elections_states:nth-child(2) tr")

				# remove first row
				table_elements.shift

				table_elements.each do |election_row|

					party = election_row.css("td:nth-child(2)").text.to_s
					presidential_candidate = election_row.css("td:nth-child(4)").text.to_s
					vice_presidential_candidate = "" # no vp
					num_electoral_votes = election_row.css("td:nth-child(5)").text.to_s
					percent_electoral_votes = election_row.css("td:nth-child(6)").text.to_s
					popular_votes = election_row.css("td:nth-child(8)").text.to_s
					percent_popular_votes = election_row.css("td:nth-child(9)").text.to_s

					nominees[presidential_candidate] = {}
					nominees[presidential_candidate]["party"] = party
					nominees[presidential_candidate]["vp"] = vice_presidential_candidate
					nominees[presidential_candidate]["electoral_votes"] = num_electoral_votes
					nominees[presidential_candidate]["percent_electoral_votes"] = percent_electoral_votes
					nominees[presidential_candidate]["popular_votes"] = popular_votes
					nominees[presidential_candidate]["percent_popular_votes"] = percent_popular_votes
				end
		end # finish scraping nominees data

		# this contains final corpus of data
		elections[yr_string] = nominees
	end

	# puts elections

	json = elections.to_json
	pretty_json = JSON.parse(json)

	puts pretty_json.class

	puts ""

	puts JSON.pretty_generate(pretty_json)

	puts ""
	
	# end benchmark
	puts Time.now
end

task :grab_links => :environment do
	require 'nokogiri'
	require 'open-uri'

	home_url = "http://www.presidency.ucsb.edu/elections.php"
	doc2 = Nokogiri::HTML(open(home_url))

	# puts doc2.at_css("title").text
	# puts ""

	election_links = doc2.css(".docpres a")
	election_arr = []

	election_links.each do |link|
		election_link = link.attr('href').to_s
		full_link = "http://www.presidency.ucsb.edu/" + election_link
		election_arr.push(full_link)
	end

	puts election_arr
end

task :grab_population => :environment do
	puts Time.now
	count = 0
	counter = 0
	population = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc) }

	File.open("lib/population.txt").each do |line|
		data = line.to_s.strip
		if count == 6
			# reset counter to go in increments of 6
			count = 0
			counter = counter + 1 # increment the row count
		end

		if count == 0
			population[counter]["year"] = data
		elsif count == 1
			population[counter]["population"] = data
		elsif count == 2
			population[counter]["growth_percent"] = data
		elsif count == 3
			population[counter]["annual_change"] = data
		elsif count == 4
			population[counter]["data_note"] = data
		elsif count == 5
			population[counter]["source_link"] = data
		end

		count = count + 1
	end

	# print the hash
	count2 = 0

	population.each do |k,v|
		year = v["year"]
		pop = v["population"]
		growth = v["growth_percent"]
		annual_change = v["annual_change"]
		data_note = v["data_note"]
		source_link = v["source_link"]
		
		year = year[6..year.length] == nil ? "" : year[6..year.length]
		pop = pop[17..pop.length] == nil ? "" : pop[17..pop.length]
		growth = growth[16..growth.length] == nil ? "" : growth[16..growth.length]
		annual_change = annual_change[15..annual_change.length] == nil ? "" : annual_change[15..annual_change.length]
		data_note = data_note[11..data_note.length] == nil ? "" : data_note[11..data_note.length]
		source_link = source_link[13..source_link.length] == nil ? "" : source_link[13..source_link.length] 
		

		puts year
		puts pop
		puts growth == "" ? "empty_data" : growth
		puts annual_change == "" ? "empty_data" : annual_change
		puts data_note == "" ? "empty_data" : data_note 
		puts source_link == "" ? "empty_data" : source_link
		puts ""
		puts ""

		# create a population record
		Population.create(:year => year, :us_population => pop, :growth_percent => growth,
					:annual_change => annual_change, :data_note => data_note, :source_link => source_link)

		count2 = count2 + 1
	end

	puts "returned data for #{count2} years!"

	puts population[234]
	
	puts Time.now
end


