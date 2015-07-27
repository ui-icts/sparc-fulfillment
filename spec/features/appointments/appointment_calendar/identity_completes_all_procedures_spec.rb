require 'rails_helper'

feature 'Identity completes all Procedures', js: true do

  scenario 'User completes all procedures' do
    given_i_have_added_a_procedure_to_an_appointment(2)
    when_i_complete_all_the_procedures
    then_all_the_procedure_complete_buttons_should_be_active
    and_all_procedures_should_be_completed
  end

  def given_i_have_added_a_procedure_to_an_appointment(qty=1)
    protocol    = create_and_assign_protocol_to_me
    @participant = protocol.participants.first
    visit_group = @participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path @participant
    bootstrap_select '#appointment_select', visit_group.name
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: qty
    find('button.add_service').click
    wait_for_ajax
    find('button.start_visit').click
    wait_for_ajax
  end

  def when_i_complete_all_the_procedures
    find('.complete_all_button').click
    wait_for_ajax
  end

  def then_all_the_procedure_complete_buttons_should_be_active
    expect(page).to have_css('label.status.complete.active', count: 2)
  end

  def and_all_procedures_should_be_completed
    expect(@participant.procedures.first.status).to eq("complete")
    expect(@participant.procedures.last.status).to eq("complete")
  end
end
