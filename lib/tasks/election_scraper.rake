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
	table_elements= doc.css("dl+ .wikitable tr")
	#remove first element
	table_elements.shift()
	winners = []
	parties = []
	table_elements.each do |election_row|
		raw_winner_text = election_row.css("td:nth-child(3)").text

		winner = parse_winner_from_text(raw_winner_text)
		party_of_winner = parse_party_of_winner(raw_winner_text)

		year = election_row.css("td:nth-child(2)").text
		year_link = election_row.css("td:nth-child(2) a").attr('href')
		
		
		# must visit each year link and scrape info about nominees and election
		# create full path to wiki article
		year_link = "https://en.wikipedia.org" + year_link.to_s
		puts year_link
		# open second article
		election_html_doc = Nokogiri::HTML(open(year_link))

		# this is where extraction of all election results and nominees happens

		# first extract the year and split into array of start and end dates
		raw_election_dates = election_html_doc.css(".noprint+ td b").text
		election_duration = parse_election_duration(raw_election_dates)
		raw_electoral_votes = election_html_doc.css("small:nth-child(1)")[0].text
		total_electoral_votes = parse_election_eletoral_votes(raw_electoral_votes)
		puts total_electoral_votes
		# some possible suggestions for selector gadget -- off by one row for early elections
		# .vevent tbody tr:nth-child(3) td table tbody tr:nth-child(5)

		# extract popular and electoral votes

		winners.append(winner)
		if not(parties.include?(party_of_winner))
			parties.append(party_of_winner)
		end


		count = count + 1
	end
	puts "-----------------"
	puts parties
	puts "---------------"
	puts winners
	puts "returned #{count} results"
end

def parse_election_eletoral_votes(raw_text)
	return raw_text[/[0-9]+/].to_i
end

def parse_election_duration(raw_text)
	election_year = raw_text.to_s # convert to string
	splitted  = election_year.split("–")
	election_duration = ElectionDuration.new
	if(splitted.length != 1)
		election_duration.start_date = splitted[0].strip+ ","+splitted[1].split(",")[1]
		election_duration.end_date = splitted[1].strip
	else
		election_duration.start_date = splitted[0].strip
		election_duration.end_date = splitted[0].strip
	end
	return election_duration
end
def parse_winner_from_text(raw_text)
	
	 winner_text = /[A-Za-z\s.]+/.match(raw_text)[0]
	 return winner_text.strip()
end

def parse_party_of_winner(raw_text)
	party_text = /\([A-Za-z\s\-]+\)/.match(raw_text)[0]
	party_text.strip()
	return party_text[1..party_text.length-2]
end

class ElectionDuration
	def initialize()
        @start_date = nil 
        @end_date = nil
    end

    attr_accessor :start_date, :end_date

end