class Sparc::LineItemsVisit < ActiveRecord::Base

  include SparcShard

  belongs_to :line_item
  belongs_to :arm
  has_many :visits
end
