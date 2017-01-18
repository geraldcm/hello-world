class Poll < ActiveRecord::Base
  #attr_accessible :name, :open
  has_many :candidates
end
