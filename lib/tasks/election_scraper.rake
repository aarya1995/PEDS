# Algorithm Steps:
# open up first link:
# loop through each row in the wiki table
# visit each election year hyperlink
# open up that link and scrape data about election and nominees
# This script can be run through the terminal: "rake scrape_election_results"
# .elections_states tr:nth-child(1) tr
# .elections_states:nth-child(2) (for older elections)
# .elections_states:nth-child(1) (for newer ones)

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
	elections = []
	table_elements.each do |election_row|
		election = {}
		#parsing BIG election table
		raw_winner_text = election_row.css("td:nth-child(3)").text
		winner = parse_winner_from_text(raw_winner_text)
		party_of_winner = parse_party_of_winner(raw_winner_text)
		winners.append(winner)
		if not(parties.include?(party_of_winner))
			parties.append(party_of_winner)
		end
		
		
		# open second article
		election_html_doc = Nokogiri::HTML(open(get_detailed_page_link(election_row)))

		# this is where extraction of all election results and nominees happens
		# first extract the year and split into array of start and end dates

		raw_election_dates = election_html_doc.css(".noprint+ td b").text
		raw_electoral_votes = election_html_doc.css("small:nth-child(1)")[0].text
		raw_turnout = election_html_doc.css(".vevent table tr:nth-child(3) td").text
		election_duration = parse_election_duration(raw_election_dates)
		election["start_date"]=election_duration.start_date
		election["end_date"]=election_duration.end_date

		election["total_electoral_votes"] = parse_election_eletoral_votes(raw_electoral_votes)
		election["voter_turnout"]=  parse_voter_turnout(raw_turnout)
		
		# some possible suggestions for selector gadget -- off by one row for early elections
		# .vevent tbody tr:nth-child(3) td table tbody tr:nth-child(5)

		# extract popular and electoral votes
		elections.append(election)
		count = count + 1
	end
	
	File.open('./lib/tasks/election_table_data.json', 'w') { |file| file.write(JSON.generate(elections)) }
	puts "-----------------"
	puts parties
	puts "---------------"
	puts winners
	puts "returned #{count} results"
end


def get_detailed_page_link(election_row)
	year = election_row.css("td:nth-child(2)").text
	year_link = election_row.css("td:nth-child(2) a").attr('href')
	# must visit each year link and scrape info about nominees and election
	# create full path to wiki article
	year_link = "https://en.wikipedia.org" + year_link.to_s

	puts year_link
	return year_link
end
def parse_election_eletoral_votes(raw_text)
	return raw_text[/[0-9]+/].to_i
end
def parse_voter_turnout(raw_text)
	return raw_text[/[0-9]+[\.0-9]*%/]
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

class Election
	def initialize()
		@election_duration = nil
		@total_electoral_votes = 0
		@total_popular_votes =0
		@voter_turnout = ""
	end

	attr_accessor :election_duration,:total_electoral_votes, :total_popular_votes, :voter_turnout
end