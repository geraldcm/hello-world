class Candidate < ActiveRecord::Base
  #attr_accessible :name, :poll_id
  has_many :votes
end
