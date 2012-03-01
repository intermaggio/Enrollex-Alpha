class Camper < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :courses
  def name
    self.first_name + ' ' + self.last_name
  end
end
