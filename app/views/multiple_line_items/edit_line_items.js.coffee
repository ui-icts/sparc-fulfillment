$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_schedule/management/manage_services/remove_line_items_form', locals: {arms: @arms, all_services: @all_services, service: @service, protocol: @protocol, page_hash: @page_hash, schedule_tab: @schedule_tab})) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()
