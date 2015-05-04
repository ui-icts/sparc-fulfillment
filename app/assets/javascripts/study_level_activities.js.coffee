$ ->

  $('.date_started_field').datetimepicker(format: 'MM-DD-YYYY', useCurrent: false)
  $('.fulfillment_date_field').datetimepicker(format: 'MM-DD-YYYY', useCurrent: false)

  $(document).on 'click', '.otf_note_new', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'add line_item note modal here'

  $(document).on 'click', '.otf_notes', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'view line_item notes modal here'

  $(document).on 'click', '.otf_document_new', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'add line_item document modal here'

  $(document).on 'click', '.otf_documents', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'view line_item documents modal here'

  $(document).on 'click', '.otf_fulfillment_new', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    alert 'add line_item fulfillment modal here'

  $(document).on 'change', '.quantity_requested_field', ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    data = line_item: quantity_requested : $(this).val()
    $.ajax
      type: 'PATCH'
      url:  "/line_items/#{line_item_id}"
      data: data

  $('.date_started_field').on 'dp.change', (e) ->
    line_item_id = $(this).parents('.row.line_item').data('id')
    data = line_item: started_at : "#{e.date}"
    $.ajax
      type: 'PATCH'
      url:  "/line_items/#{line_item_id}"
      data: data

  $(document).on 'change', '.component_check', ->
    component_id = $(this).val()
    data = component: selected: $(this).is(':checked')
    $.ajax
      type: 'PATCH'
      url:  "/components/#{component_id}"
      data: data

  $(document).on 'click', '.otf_fulfillments', ->
    id = $(this).parents('.row.line_item').data('id')
    table = $("#fulfillments_list_#{id}")
    if table.hasClass('slide-active')
      table.removeClass('slide-active')
      table.addClass('slide-inactive')
      table.slideToggle()
    else
      activeSlide = $('.slide-active')
      if activeSlide.length != 0
        activeSlide.removeClass('slide-active')
        activeSlide.addClass('slide-inactive')
        activeSlide.slideToggle()
      table.removeClass('slide-inactive')
      table.addClass('slide-active')
      table.slideToggle()

  $('.fulfillment_date_field').on 'dp.change', (e) ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    data = fulfillment: fulfilled_at : "#{e.date}"
    $.ajax
      type: 'PATCH'
      url:  "/fulfillments/#{fulfillment_id}"
      data: data

  $(document).on 'change', '.quantity_fulfilled_field', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    data = fulfillment: quantity: $(this).val()
    $.ajax
      type: 'PATCH'
      url:  "/fulfillments/#{fulfillment_id}"
      data: data

  $(document).on 'change', '.fulfillment_performed_by', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    data = fulfillment: performed_by: $(this).val()
    $.ajax
      type: 'PATCH'
      url:  "/fulfillments/#{fulfillment_id}"
      data: data

  $(document).on 'click', '.fulfillment_note_new', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    alert 'add fulfillment note modal here'

  $(document).on 'click', '.fulfillment_notes', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    alert 'view fulfillment notes modal here'

  $(document).on 'click', '.fulfillment_document_new', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    alert 'add fulfillment document modal here'

  $(document).on 'click', '.fulfillment_documents', ->
    fulfillment_id = $(this).parents('.row.fulfillment').data('id')
    alert 'view fulfillment documents modal here'

  $(document).on 'change', '.fulfillment_component', ->
    component_id = $(this).data('id')
    data = component: component: $(this).val()
    $.ajax
      type: 'PATCH'
      url:  "/components/#{component_id}"
      data: data

  $(document).on 'click', ".otf_service_new", ->
    service_id = $('#otf_select').find('option:selected').val()
    protocol_id = $('#protocol_id').val()
    data = 
          'service_id': service_id
          'protocol_id': protocol_id
    $.ajax
      type: 'POST'
      url: "/line_items"
      data: data
