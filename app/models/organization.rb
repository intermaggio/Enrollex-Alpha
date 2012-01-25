class Organization < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.find_by_subdomain subdomain
    Organization.where(subname: subdomain).first
  end

  before_create do
    self.subname = self.name.downcase.gsub(' ', '_')
  end

end
