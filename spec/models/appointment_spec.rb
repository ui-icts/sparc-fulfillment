require 'rails_helper'

RSpec.describe Appointment, type: :model do

  it { should belong_to(:participant) }
  it { should belong_to(:visit_group) }

  it { should have_many(:procedures) }

  context 'instance methods' do

    describe 'has_completed_procedures?' do
      before :each do
        @appt = create(:appointment)
        @proc1 = create(:procedure, appointment: @appt)
        @proc2 = create(:procedure, appointment: @appt)
      end

      it 'should return true when appt has completed procedures' do
        @proc1.completed_date = Time.now
        @proc1.save
        expect(@appt.has_completed_procedures?).to be true
      end

      it 'should return false when appt doesnt have completed procedures' do
        expect(@appt.has_completed_procedures?).to be false
      end
    end

    describe 'initialize_procedures' do
      before :each do
        service1 = create(:service, name: 'A')
        service2 = create(:service, name: 'B')
        protocol = create(:protocol)
        arm = create(:arm, protocol: protocol)
        participant = create(:participant, protocol: protocol, arm: arm)
        line_item1 = create(:line_item, arm: arm, service: service1)
        line_item2 = create(:line_item, arm: arm, service: service2)
        visit_group = create(:visit_group, arm: arm)
        @visit_li1 = create(:visit, visit_group: visit_group, line_item: line_item1)
        @visit_li2 = create(:visit, visit_group: visit_group, line_item: line_item2)
        @appt = create(:appointment, visit_group: visit_group, participant: participant)
      end

      it 'should not create a procedure if there is no visit for a line_item' do
        @visit_li1.destroy
        @visit_li2.update_attribute(:research_billing_qty, 1)
        @appt.initialize_procedures
        services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
        expect(services_of_procedures).to eq(['B'])
      end

      it 'should not create a procedure if the visit has no billing' do
        @appt.initialize_procedures
        services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
        expect(services_of_procedures).to eq([])
      end

      it 'should create procedures for each line_item' do
        @visit_li1.update_attribute(:research_billing_qty, 1)
        @visit_li2.update_attribute(:research_billing_qty, 1)
        @appt.initialize_procedures
        services_of_procedures = @appt.procedures.map{ |proc| proc.service_name }
        expect(services_of_procedures).to eq(['A','B'])
      end
    end
  end
end