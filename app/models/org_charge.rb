class OrgCharge < ActiveRecord::Base
  belongs_to :organization
  validates_uniqueness_of :stripe_id, scope: :organization_id
end
