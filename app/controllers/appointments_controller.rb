class AppointmentsController < ApplicationController

  respond_to :json, :html
  
  #### BEGIN CUSTOM APPOINTMENTS ####
  
  def new 
    @appointment = CustomAppointment.new(custom_appointment_params)
    @note = @appointment.notes.new(kind: 'reason')
  end

  def create 
    ##### TODO, figure out a way to not have to use base model
    @appointment = Appointment.new(custom_appointment_params)

    if @appointment.valid?
      @appointment.save
      @appointment.update_attribute(:type, "CustomAppointment")
    end
  end
  
  #### END CUSTOM APPOINTMENTS ####

  def show
    @appointment = Appointment.find params[:id]
    @statuses = @appointment.appointment_statuses.map{|x| x.status}
    if @appointment.procedures.empty?
      @appointment.initialize_procedures
    end
  end

  def completed_appointments
    participant = Participant.find(params[:participant_id])
    @appointments = participant.appointments.completed
    respond_with @appointments
  end

  def update
    @appointment = Appointment.find params[:id]

    if params[:contents]
      @appointment.update_attributes(contents: params[:contents])
    end

    if ['start_date', 'completed_date'].include? params[:field]
      @field = params[:field]
      if params[:new_date]
        updated_date = Time.at(params[:new_date].to_i / 1000)
      else
        updated_date = Time.current
      end
      if @field == 'start_date'
        @appointment.update_attributes(start_date: updated_date)
      elsif @field == 'completed_date'
        updated_date = @appointment.start_date if !@appointment.start_date.blank? && @appointment.start_date > updated_date #completed date cannot be before start date
        @appointment.update_attributes(completed_date: updated_date)
      end

    elsif params[:statuses]
      new_statuses = params[:statuses]
      @appointment.appointment_statuses.destroy_all

      if params[:statuses].present?
        new_statuses.each do |status|
          @appointment.appointment_statuses.create(status: status)
        end
      end
    end
  end

  private

  def show_time in_time
    in_time.blank? ? Time.now : in_time
  end

  def custom_appointment_params
    params.require(:custom_appointment)
          .permit(:arm_id, :participant_id, :name, :position, 
                 notes_attributes: [:comment, :kind, :user_id, :reason])
  end
end
