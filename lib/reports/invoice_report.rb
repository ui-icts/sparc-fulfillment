# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class InvoiceReport < Report

  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date, :sort_by, :sort_order, :organizations, :protocols].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  # A protocol with subsidy, format protocol_id column with an 's'
  # A protocol without subsidy, format protcol_id column without an 's'
  def format_protocol_id_column(protocol)
    protocol.subsidies.any? ? protocol.sparc_id.to_s + 's' : protocol.sparc_id
  end

  def display_subsidy_percent(protocol)
    if protocol.sub_service_request.subsidy
      "#{protocol.sub_service_request.subsidy.percent_subsidy * 100}%"
    else
      ""
    end
  end

  def generate(document)
    #We want to filter from 00:00:00 in the local time zone,
    #then convert to UTC to match database times
    @start_date = Time.strptime(@params[:start_date], "%m/%d/%Y").utc
    #We want to filter from 11:59:59 in the local time zone,
    #then convert to UTC to match database times
    @end_date   = Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|
      csv << ["From", format_date(Time.strptime(@params[:start_date], "%m/%d/%Y")), "To", format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))]
      csv << [""]

      if @params[:sort_by] == "Protocol ID"
        protocols = Protocol.where(id: @params[:protocols]).sort_by(&:sparc_id)
      else
        protocols = Protocol.where(id: @params[:protocols]).sort_by{ |protocol| protocol.pi.full_name }
      end

      if @params[:sort_order] == "DESC"
        protocols.reverse!
      end

      protocols.each do |protocol|
        total = 0
        total_with_subsidy = 0

        fulfillments = protocol.fulfillments.fulfilled_in_date_range(@start_date, @end_date)
        procedures = protocol.procedures.completed_r_in_date_range(@start_date, @end_date)

        if fulfillments.any?
          csv << ["Non-clinical Services"]

          header = []
          header << "Protocol ID"
          header << "Request ID"
          header << "RMID" if ENV.fetch('RMID_URL'){nil}
          header << "Short Title"
          header << "Funding Source"
          header << "Status"
          header << "Primary PI"
          header << "Primary PI Affiliation"
          header << "Billing/Business Manager(s)"
          header << "Core/Program"
          header << "Service"
          header << "Fulfillment Date"
          header << "Performed By"
          header << "Components"
          header << "Notes" if @params[:include_notes] == "true"
          header << "Contact"
          header << "Account #"
          header << "Quantity Completed"
          header << "Quantity Type"
          header << "Research Rate"
          header << "Total Cost"
          header << "Percent Subsidy" if protocol.sub_service_request.subsidy
          header << "MFK"
          
          csv << header

          fulfillments.includes(:line_item, service: [:organization]).order("organizations.name, line_items.quantity_type, fulfilled_at").each do |fulfillment|
            data = []
            data << format_protocol_id_column(protocol)
            data << protocol.sub_service_request.ssr_id
            data << protocol.research_master_id if ENV.fetch('RMID_URL'){nil}
            data << protocol.sparc_protocol.short_title
            data << fulfillment.funding_source
            data << formatted_status(protocol)
            data << (protocol.pi ? protocol.pi.full_name : nil)
            data << (protocol.pi ? [protocol.pi.professional_org_lookup("institution"), protocol.pi.professional_org_lookup("college"),
                                   protocol.pi.professional_org_lookup("department"), protocol.pi.professional_org_lookup("division")].compact.join("/") : nil)
            data << protocol.billing_business_managers.map(&:full_name).join(',')
            data << fulfillment.service.organization.name
            data << fulfillment.service_name
            data << format_date(fulfillment.fulfilled_at)
            data << fulfillment.performer.full_name
            data << fulfillment.components.map(&:component).join(',')
            data << fulfillment.notes.map(&:comment).join(' | ') if @params[:include_notes] == "true"
            data << fulfillment.line_item.contact_name
            data << fulfillment.line_item.account_number
            data << fulfillment.quantity
            data << fulfillment.line_item.quantity_type
            data << display_cost(fulfillment.service_cost)
            data << display_cost(fulfillment.total_cost)
            data << display_subsidy_percent(protocol)

            csv << data

            total += fulfillment.total_cost
            total_with_subsidy += protocol.sub_service_request.subsidy ? fulfillment.total_cost * (1 - protocol.sub_service_request.subsidy.percent_subsidy) : fulfillment.total_cost
          end
        end

        if procedures.any?
          csv << [""]
          csv << [""]

          csv << ["Clinical Services:"]

          header = []
          header << "Protocol ID"
          header << "Request ID"
          header << "RMID" if ENV.fetch('RMID_URL'){nil}
          header << "Short Title"
          header << "Funding Source"
          header << "Status"
          header << "Primary PI"
          header << "Primary PI Affiliation"
          header << "Billing/Business Manager(s)"
          header << "Core/Program"
          header << "Service"
          header << "Service Completion Date"
          header << "Patient Name"
          header << "Patient ID"
          header << "Notes" if @params[:include_notes] == "true"
          header << "Visit Name"
          header << "Visit Date"
          header << "Quantity Completed"
          header << "Clinical Quantity Type"
          header << "Research Rate"
          header << "Total Cost"
          header << "Percent Subsidy" if protocol.sub_service_request.subsidy
          header << "MFK"
          csv << header

          procedures.group_by{|procedure| procedure.service.organization}.each do |org, org_group|

            org_group.group_by{|procedure| procedure.appointment.visit_group}.each do |visit_group, vg_group|

              vg_group.group_by(&:appointment).each do |appointment, appointment_group|
                participant = appointment.participant

                appointment_group.group_by(&:service_name).each do |service_name, service_group|
                  procedure = service_group.first

                  data = []
                  data << format_protocol_id_column(protocol)
                  data << protocol.sub_service_request.ssr_id
                  data << protocol.research_master_id if ENV.fetch('RMID_URL'){nil}
                  data << protocol.sparc_protocol.short_title
                  data << procedure.funding_source
                  data << formatted_status(protocol)
                  data << (protocol.pi ? protocol.pi.full_name : nil)
                  data << (protocol.pi ? [protocol.pi.professional_org_lookup("institution"), protocol.pi.professional_org_lookup("college"),
                                        protocol.pi.professional_org_lookup("department"), protocol.pi.professional_org_lookup("division")].compact.join("/") : nil)
                  data << protocol.billing_business_managers.map(&:full_name).join(',')
                  data << org.name
                  data << service_name
                  data << format_date(procedure.completed_date)
                  data << participant.full_name
                  data << participant.label
                  data << procedure.notes.map(&:comment).join(' | ') if @params[:include_notes] == "true"
                  data << appointment.name
                  data << format_date(appointment.start_date)
                  data << service_group.size
                  data << procedure.service.current_effective_pricing_map.unit_type
                  data << display_cost(procedure.service_cost)
                  data << display_cost(service_group.size * procedure.service_cost.to_f)
                  data << display_subsidy_percent(protocol)
                  data << protocol.sparc_protocol.try(:udak_project_number)

                  csv << data

                  service_cost = service_group.size * procedure.service_cost.to_f
                  total += service_cost
                  total_with_subsidy += protocol.sub_service_request.subsidy ? service_cost * (1 - protocol.sub_service_request.subsidy.percent_subsidy) : service_cost
                end
              end
            end
          end
        end
        if fulfillments.any? or procedures.any?
          csv << [""]
          csv << ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Non-clinical and Clinical Services Total:", display_cost(total)]
          csv << ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Total Cost after Subsidy:", display_cost(total_with_subsidy)] if protocol.sub_service_request.subsidy
          csv << [""]
          csv << [""]
        end
      end
    end
  end
end
