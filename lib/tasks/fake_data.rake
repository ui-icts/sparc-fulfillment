require 'factory_girl'

namespace :data do

  desc 'Create fake data in CWF'
  task generate_data: :environment do

    # Globally unique :sparc_ids
    FactoryGirl.define { sequence(:sparc_id) }

    # Create Indentity
    Identity.where( email: "email@musc.edu").destroy_all
    identity = FactoryGirl.create(:identity, email: 'email@musc.edu', ldap_uid: 'ldap@musc.edu', password: 'password')

    # Create 10 Protocols
    2.times do
      service_request     = FactoryGirl.create(:service_request)
      5.times do
        sub_service_request = FactoryGirl.create(:sub_service_request_with_organization, service_request: service_request)
        protocol            = FactoryGirl.create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
        organization        = sub_service_request.organization
        FactoryGirl.create(:clinical_provider, identity: identity, organization: organization)
      end
    end

    # Create 10 tasks
    10.times do
      identity.tasks.push FactoryGirl.create(:task, assignee: identity)
    end
  end
end
