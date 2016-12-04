class Nominee < ActiveRecord::Base
	belongs_to :person
	belongs_to :election
	belongs_to :party
	has_many :polls
	belongs_to :president
end
