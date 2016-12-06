# Algorithm Steps:
# open up first link:
# loop through each row in the wiki table
# visit each election year hyperlink
# open up that link and scrape data about election and nominees
# This script can be run through the terminal: "rake scrape_election_results"


desc "scrape election data"
task :scrape_election_results => :environment do
	require 'nokogiri'
	require 'open-uri'

	url = "https://en.wikipedia.org/wiki/United_States_presidential_election"
	doc = Nokogiri::HTML(open(url))
	puts doc.at_css("title").text
	
	count = 0
	doc.css("dl+ .wikitable tr").each do |election_row|
		winner = election_row.css("td:nth-child(3)").text
		year = election_row.css("td:nth-child(2)").text

		if (count >= 1) # first scraped result is garbage data I don't know how to get rid of
			year_link = election_row.css("td:nth-child(2) a").attr('href')
		end
		
		# must visit each year link and scrape info about nominees and election
		# puts year_link
		
		# create full path to wiki article
		year_link = "https://en.wikipedia.org" + year_link.to_s
		
		# open second article
		doc2 = Nokogiri::HTML(open(year_link))

		# this is where extraction of all election results and nominees happens

		# first extract the year and split into array of start and end dates
		election_year = doc2.css(".noprint+ td b").text
		election_year = election_year.to_s # convert to string
		election_duration = election_year.split("–")

		# secondly extract nominees 
		# some possible suggestions for selector gadget -- off by one row for early elections
		# .vevent tbody tr:nth-child(3) td table tbody tr:nth-child(5)

		# extract popular and electoral votes

		puts "#{winner}"
		puts "#{election_duration}"

		puts ""
		puts ""

		count = count + 1
	end

	puts "returned #{count} results"
end