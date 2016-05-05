class VisitGroup < ActiveRecord::Base
  self.per_page = Visit.per_page

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: [:arm_id]

  before_destroy :check_for_completed_data

  belongs_to :arm

  has_many :visits, dependent: :destroy
  has_many :line_items, through: :arm
  has_many :appointments

  default_scope { order(:position) }

  validates :arm_id,
            :name,
            :position,
            presence: true

  validates :day, presence: true, unless: "ENV.fetch('USE_EPIC'){nil} == 'false'"

  validate :day_must_be_in_order, unless: "day.blank? || arm_id.blank?"
  validates :day, numericality: { only_integer: true }, unless: "day.blank?"

  def r_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:research_billing_qty)
  end

  def t_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:insurance_billing_qty)
  end

  private

  def check_for_completed_data
    self.appointments.each { |appt| appt.destroy_if_incomplete }
  end

  # Used to validate :day, when present. Preceding VisitGroup must have a
  # a smaller :day, and succeeding VisitGroup must have a larger :day (on same Arm).
  def day_must_be_in_order
    # determine neighbors that will be after save
    already_there = arm.visit_groups.find_by(position: position)
    left_neighbor, right_neighbor =
      if id.nil? # inserting before
        [already_there.try(:higher_item), already_there]
      else
        if already_there.try(:id) == id # not changing position, get our neighbors
          [higher_item, lower_item]
        else # position must be changing
          if already_there.position < changed_attributes[:position]
            [already_there.try(:higher_item), already_there]
          else
            [already_there, already_there.try(:lower_item)]
          end
        end
      end

    unless day > (left_neighbor.try(:day) || day - 1) && day < (right_neighbor.try(:day) || day + 1)
      errors.add(:day, 'must be in order')
    end
  end
end
