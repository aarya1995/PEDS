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

		puts "#{winner} -- #{year}"
		puts year_link # must visit each year link and scrape info about nominees and election

		puts ""
		puts ""

		count = count + 1
	end

	puts "returned #{count} results"
end