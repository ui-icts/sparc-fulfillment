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

class ParticipantsController < ApplicationController

  before_action :find_protocol, only: [:details, :destroy, :participants_in_protocol, :edit_arm, :participants_not_in_protocol, :update_protocol_association, :search]
  before_action :find_participant, only: [:details, :show, :edit, :update, :destroy, :edit_arm, :update_arm, :details, :update_protocol_association]
  before_action :find_protocol_participant, only: [:details, :edit_arm, :destroy, :update_arm, :assign_arm_if_only_one_arm]
  before_action :note_old_participant_attributes, only: [:update, :update_arm]
  before_action :authorize_protocol, only: [:show]

  def index
    @page = params[:page]
    @status = params[:status] || 'all'
    @offset = params[:offset] || 0
    @limit = params[:limit] || 25

    find_participants_for_index

    respond_to do |format|
      format.html
      format.json
    end
  end

  def find_participants_for_index
    @participants = Participant.all
    @total = @participants.count
    search_participant_attrs
    @participants = @participants.limit(@limit).offset(@offset)
  end

  def update_protocol_association
    if params[:checked] == 'true'
      @participant.protocols << @protocol
      assign_arm_if_only_one_arm
      flash[:success] = t(:participant)[:flash_messages][:added_to_protocol]
    else
      @participant.protocols.delete(@protocol)
      flash[:success] = t(:participant)[:flash_messages][:removed_from_protocol]
    end
  end

  def new
    respond_to do |format|
      format.js {
        @participant = Participant.new()
      }
    end
  end

  def search
    find_participants_for_index
    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    @participant.build_appointments

    gon.push({appointment_id: params[:appointment_id]})
  end

  def create
    @participant = Participant.new(participant_params)

    if @participant.valid?
      @participant.save
      
      flash[:success] = t(:participant)[:flash_messages][:created]
    else
      @errors = @participant.errors
    end
  end

  def update
    if @participant.update_attributes(participant_params)
      note_successful_changes
      flash[:success] = t(:participant)[:flash_messages][:updated]
    else
      @errors = @participant.errors
    end
  end

  def destroy
    @protocol_participant.destroy
    flash[:alert] = t(:participant)[:flash_messages][:removed]
  end

  def update_arm
    @protocol_participant.update_attributes(arm_id: participant_params[:arm_id])
    @protocol_participant.update_appointments_on_arm_change
    note_successful_changes

    flash[:success] = t(:participant)[:flash_messages][:arm_change]
  end

  def participants_in_protocol
    respond_to do |format|
      format.json {
        @participants = Participant.by_protocol_id(@protocol.id)

        render
      }
    end
  end

  def participants_not_in_protocol
    page = params[:page]
    @status = params[:status] || 'all'
    @offset = params[:offset] || 0
    @limit = params[:limit] || 25

    find_participants_for_index

    respond_to do |format|
      format.json
      format.js
    end
  end

  private

  def search_participant_attrs
    if params[:search] && !params[:search].blank?
      search_term = params[:search]

      query_string = "participants.mrn LIKE ? " # search by mrn
      query_string += "OR participants.first_name LIKE ? " # search by first name
      query_string += "OR participants.last_name LIKE ? " # search by last name

      @participants = @participants.where(query_string, "%#{search_term}%", "%#{search_term}%", "%#{search_term}%")

      @total = @participants.count
    end
  end

  def find_protocol
    @protocol = Protocol.find(params[:protocol_id])
  end

  def find_protocol_participant
    @protocol_participant = ProtocolsParticipant.where(protocol_id: @protocol.id, participant_id: @participant.id).first
  end

  def participant_params
    params.require(:participant).permit(:protocol_id, :arm_id, :last_name, :first_name, :middle_initial, :mrn, :external_id, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :city, :state, :zipcode, :phone, :recruitment_source)
  end

  def find_participant
    participant_id = params[:id] || params[:participant_id]
    @participant = Participant.where(id: participant_id).first

    if !@participant.present?
      flash[:alert] = t(:participant)[:flash_messages][:not_found]
      redirect_to root_path
    end
  end

  def assign_arm_if_only_one_arm
    if @protocol.arms.size == 1
      @protocol_participant.update_attributes(arm_id: @protocol.arms.first.id)
      @protocol_participant.update_appointments_on_arm_change
    end
  end

  def note_old_participant_attributes
    @old_attributes = @participant.attributes
  end

  def note_successful_changes
    if participant_params[:status] and ( @old_attributes["status"] != participant_params[:status] ) # Status Changed
      old_status = @old_attributes["status"].blank? ? t(:actions)[:n_a] : @old_attributes["status"]
      new_status = participant_params[:status].blank? ? t(:actions)[:n_a] : participant_params[:status]
      @participant.notes.create(identity: current_identity, comment: "Status changed from #{old_status} to #{new_status}")
    end

    if participant_params[:arm_id] and ( @old_attributes["arm_id"].to_s != participant_params[:arm_id] ) # Arm Changed
      old_arm = @old_attributes["arm_id"].blank? ? t(:actions)[:n_a] : Arm.find(@old_attributes["arm_id"]).name
      new_arm = participant_params[:arm_id].blank? ? t(:actions)[:n_a] : Arm.find(participant_params[:arm_id]).name
      @participant.notes.create(identity: current_identity, comment: "Arm changed from #{old_arm} to #{new_arm}")
    end
  end
end
