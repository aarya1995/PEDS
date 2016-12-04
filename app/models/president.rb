class President < ActiveRecord::Base
	belongs_to :person
	has_many :elections
	belongs_to :nominee
	belongs_to :party
end
