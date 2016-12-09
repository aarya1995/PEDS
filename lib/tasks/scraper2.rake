# .elections_states:nth-child(1) tr:nth-child(6) td:nth-child(2)
# 1824 is the last election with available popular vote data on ucsb
# 1800 and older elections only returning second nominee
# also no vp for 1800 and older elections and no popular votes either

desc "scrape election data"

task :grab_nominee_data => :environment do
	require 'nokogiri'
	require 'open-uri'

	url = "http://www.presidency.ucsb.edu/showelection.php?year=1936"
	doc = Nokogiri::HTML(open(url))

	# extract year from the title to determine which scraping algo to use
	puts doc.at_css("title").text 
	yr_string = doc.at_css("title").text.to_s
	election_year = yr_string[0..3].to_i
	
	count = 0
	nominees = {}

	puts ""

	# output links to all elections here #

	puts ""

	if election_year > 1924 # works with all elections after 1924

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
			
			puts presidential_candidate
			puts nominees[presidential_candidate]
			puts ""
			puts ""
			count = count + 1		
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
			
			puts presidential_candidate
			puts nominees[presidential_candidate]
			puts ""
			puts ""
			count = count + 1
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
				
				puts presidential_candidate
				puts nominees[presidential_candidate]
				puts ""
				puts ""
				count = count + 1	
			end
	end

	puts "number of rows in this table is: #{ count }"
	puts ""
	puts ""

	puts nominees
end