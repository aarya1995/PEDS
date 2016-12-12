class Person < ActiveRecord::Base
	has_many :nominees
	has_many :presidents

	def self.getFullName(person)
		first_name = person.first_name
		middle_name = person.middle_name
		last_name = person.last_name

		if (middle_name == "")
			full_name = first_name + " " + last_name
		else 
			full_name = first_name + " " + middle_name + " " + last_name
		end

		return full_name
	end
end
