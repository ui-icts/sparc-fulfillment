class Participant < ActiveRecord::Base

  ETHNICITY_OPTIONS = ['Hispanic or Latino', 'Not Hispanic or Latino'].freeze
  RACE_OPTIONS      = ['Caucasian', 'African American/Black', 'Asian', 'Middle Eastern', 'Pacific Islander', 'Native American/Alaskan', 'Other'].freeze
  STATUS_OPTIONS    = ['Active', 'Inactive', 'Complete'].freeze
  GENDER_OPTIONS    = ['Male', 'Female'].freeze

  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  has_many :appointments

  after_save :update_via_faye

  validates :protocol_id, :first_name, :last_name, :mrn, :date_of_birth, :ethnicity, :race, :gender, presence: true
  validate :phone_number_format, :date_of_birth_format

  def phone_number_format
    unless (phone.strip.empty? or /^\d{3}-\d{3}-\d{4}$/.match phone.strip)
      errors.add(:phone, "is not a phone number in the format XXX-XXX-XXXX")
    end
  end

  def date_of_birth_format
    unless /^\d{4}-\d{2}-\d{2}$/.match date_of_birth.to_s
      errors.add(:date_of_birth, "is not a date in the format YYYY-MM-DD")
    end
  end

  def build_appointments
    ActiveRecord::Base.transaction do
      if self.arm
        if self.appointments.empty?
          appointments_for_visit_groups(self.arm.visit_groups)
        elsif has_new_visit_groups?
          appointments_for_visit_groups(new_visit_groups)
        end
      end
    end
  end

  private

  def update_via_faye
    channel = "/participants/#{self.protocol.id}/list"
    message = { channel: channel, data: "woohoo", ext: { auth_token: ENV.fetch('FAYE_TOKEN') } }
    uri = URI.parse('http://' + ENV.fetch('CWF_FAYE_HOST') + '/faye')
    Net::HTTP.post_form(uri, message: message.to_json)
  end

  def has_new_visit_groups?
    self.arm.visit_groups.count > self.appointments.count
  end

  def new_visit_groups
    participant_vgs = self.appointments.map{|app| app.visit_group}
    arm_vgs = self.arm.visit_groups
    arm_vgs - participant_vgs
  end

  def appointments_for_visit_groups visit_groups
    visit_groups.each do |vg|
      self.appointments.create(visit_group_id: vg.id, visit_group_position: vg.position, position: self.appointments.count + 1, name: vg.name)
    end
  end
end
