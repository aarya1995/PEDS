class President < ActiveRecord::Base
	belongs_to :person
	has_many :elections
	belongs_to :nominee
	belongs_to :party

	def get_non_contiguous
		president_names= []
		President.find_each do 
			|president|
			 if(president.nominee_id !=nil)
 				
			 end
		end
		#group each president object with a person hash, 
	end

	
end
