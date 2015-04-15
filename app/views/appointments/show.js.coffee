$(".appointments").html("<%= escape_javascript(render(partial: 'calendar', locals: {appointment: @appointment})) %>")

if !$('.start_date_input').hasClass('hidden')
  start_date_init("<%= format_datetime(@appointment.start_date) %>")

if !$('.completed_date_input').hasClass('hidden')
  completed_date_init("<%= format_datetime(@appointment.completed_date) %>")

$(".completed_date_field").datetimepicker(format: 'MM-DD-YYYY', keepOpen: true, viewMode: 'years')
