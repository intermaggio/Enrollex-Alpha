class Template < ActiveRecord::Base
  belongs_to :organization
  has_many :courses
end
