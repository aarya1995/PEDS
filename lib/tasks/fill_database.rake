desc "fill election data"


task :fill_database => :environment do
	require 'nokogiri'
	require 'open-uri'
	require 'json'

	election_json = read_json_file()
	# Person.where(:first_name => 'first_name', :middle_name => 'middle_name', :last_name => 'last_name').first_or_create(:locked => false)
	puts Person.methods 
	create_people(election_json)

end  

def create_people(election_json) 
	election_json.keys.each  do 
		|year_key|
		if !year_key.include?("1936")
			election_json[year_key].keys.each do
				|presidential_nominee_full_name|
				create_person(presidential_nominee_full_name)
				vp_name= election_json[year_key][presidential_nominee_full_name]["vp"]
				if(vp_name.strip!="" and vp_name.strip!="none")
					create_person(vp_name)
				end
			end

		end
	end
end

def create_person(full_name)
	#might have an issue with jr/sr in name
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
	
	#puts Person.methods
	Person.where(:first_name => first_name, :middle_name => middle_name, :last_name => last_name).first_or_create()
	
	puts "--"

	#person =Person.find_or_initialize_by(first_name: first_name, middle_name: middle_name, last_name: last_name)
end
def read_json_file()
	json_string = ""
	File.open("./lib/tasks/clean_data.json", "r") do |f|
		f.each_line do |line|
			json_string+=line.strip
		end
	end
	return JSON.load(json_string)
end