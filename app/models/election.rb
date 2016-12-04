class Election < ActiveRecord::Base
	has_many :nominees
	belongs_to :president
end
