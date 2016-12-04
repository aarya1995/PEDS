class Person < ActiveRecord::Base
	has_many :nominees
	has_many :presidents
end
