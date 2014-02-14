# Useful when smart list target url is different than current one
$.rails.href = (element) ->
  element.attr('href') || element.data('href')

$.fn.observeField = (opts = {}) ->
   field = $(this)
   key_timeout = null
   last_value = null
   options =
     onFilled: () ->
     onEmpty: () ->
     onChange: () ->
   options = $.extend(options, opts)
 
   keyChange = () ->
     if field.val().length > 0
       options.onFilled()
     else
       options.onEmpty()

     if field.val() == last_value && field.val().length != 0
       return
     lastValue = field.val()
 
     options.onChange()
 
   field.data('observed', true)
 
   field.bind 'keydown', (e) ->
     if(key_timeout)
       clearTimeout(key_timeout)
 
     key_timeout = setTimeout(->
       keyChange()
     , 400)

class SmartListing
  constructor: (e) ->
    @container = e
    @name = @container.attr('id')
    @loading = @container.find('.loading')
    @content = @container.find('.content')
    @status = $(".smart_listing_status[data-smart-listing='#{@name}']")
    @confirmed = null

    createPopover = (confirmation_elem, msg) =>
      deletion_popover = $('<div/>').addClass('confirmation_box')
      deletion_popover.append($('<p/>').html(msg))
      deletion_popover.append($('<p/>')
        .append($('<button/>').html('Yes').addClass('btn btn-danger ').click (event) =>
          # set @confirmed element and emulate click on icon
          editable = $(event.currentTarget).closest('.editable')
          @confirmed = confirmation_elem
          $(confirmation_elem).click()
          $(confirmation_elem).popover('destroy')
        )
        .append(" ")
        .append($('<button/>').html('No').addClass('btn btn-small').click (event) =>
          editable = $(event.currentTarget).closest('.editable')
          $(confirmation_elem).popover('destroy')
        )
      )

    @container.on 'ajax:before', (e) =>
      @fadeLoading()

    @container.on 'ajax:success', (e) =>
      if $(e.target).is('.actions a.destroy')
        # handle HEAD OK response for deletion request
        editable = $(e.target).closest('.editable')
        if @container.find(".editable").length == 1
          @reload()
          return false
        else
          editable.remove()

        @changeItemCount(-1)
        @refresh()

        @fadeLoaded()
        return false

    @container.on 'click', 'button.cancel', (event) =>
      editable = $(event.currentTarget).closest('.editable')
      if(editable.length > 0)
        # Cancel edit
        @cancelEdit(editable)
      else
        # Cancel new record
        @container.find('.new_item_placeholder').addClass('hidden')
        @container.find('.new_item_action').removeClass('hidden')
      false

    @container.on 'click', '.actions a[data-confirmation]', (event) =>
      # Check if we are confirming the right element
      if(@confirmed != event.currentTarget)
        # We need confirmation
        @container.find('.actions a').popover('destroy')
        $(event.currentTarget).popover(content: createPopover(event.currentTarget, $(event.currentTarget).data('confirmation')), html: true, trigger: 'manual', title: null)
        $(event.currentTarget).popover('show')
        false
      else
        # Confirmed, reset flag and go ahead with deletion
        @confirmed = null
        true

    @container.on 'click', 'input[type=text].autoselect', (event) ->
      $(this).select()

    @container.on 'change', '.callback', (event) =>
      checkbox = $(event.currentTarget)
      id = checkbox.closest("tr").data("id")
      data = {}
      data[checkbox.val()] = checkbox.is(":checked")
      $.ajax({
        url: @container.data("callback-href"),
        type: "POST",
        data: data,
      })

  fadeLoading: =>
    @content.stop(true).fadeTo(500, 0.2)
    @loading.show()
    @loading.stop(true).fadeTo(500, 1)

  fadeLoaded: =>
    @content.stop(true).fadeTo(500, 1)
    @loading.stop(true).fadeTo 500, 0, () =>
      @loading.hide()

    @content.find('.play').each () ->
      self.loadAudio($(this).data('key'), $(this).data('target'))
  
  itemCount: =>
    parseInt(@container.find('.pagination_per_page .count').html())

  maxCount: =>
    parseInt(@container.data('max-count'))

  changeItemCount: (value) =>
    @container.find('.pagination_per_page .count').html(@itemCount() + value)

  cancelEdit: (editable) =>
    if editable.data('smart_listing_edit_backup')
      editable.html(editable.data('smart_listing_edit_backup'))
      editable.removeClass('info')
      editable.removeData('smart_listing_edit_backup')
  
  # Callback called when record is added/deleted using ajax request
  refresh: () =>
    header = @content.find('thead')
    footer = @content.find('.pagination_per_page')
    no_records = @content.find('.no_records')

    if @itemCount() == 0
      header.hide()
      footer.hide()
      no_records.show()
    else
      header.show()
      footer.show()
      no_records.hide()

    if @maxCount()
      if @itemCount() >= @maxCount()
        if @itemCount()
          @container.find('.new_item_action').addClass('hidden')
        @container.find('.new_item_action .btn').addClass('hidden')
      else
        @container.find('.new_item_action').removeClass('hidden')
        @container.find('.new_item_action .btn').removeClass('hidden')

    @status.each (index, status) =>
      $(status).find('.smart_listing_limit').html(@maxCount() - @itemCount())
      if @maxCount() - @itemCount() == 0
        $(status).find('.smart_listing_limit_alert').show()
      else
        $(status).find('.smart_listing_limit_alert').hide()
  
  # Trigger AJAX request to reload the list
  reload: () =>
    $.rails.handleRemote(@container)
  
  params: () =>
    @container.data('params')
  
  #################################################################################################
  # Methods executed by rails UJS:

  new_item: (content) =>
    new_item_action = @container.find('.new_item_action')
    new_item_placeholder = @container.find('.new_item_placeholder').addClass('hidden')

    @container.find('.editable').each (i, v) =>
      @cancelEdit($(v))

    new_item_action.addClass('hidden')
    new_item_placeholder.removeClass('hidden')
    new_item_placeholder.html(content)
    new_item_placeholder.addClass('info')

    @fadeLoaded()

  create: (id, success, content) =>
    new_item_action = @container.find('.new_item_action')
    new_item_placeholder = @container.find('.new_item_placeholder')

    if success
      new_item_placeholder.addClass('hidden')
      new_item_action.removeClass('hidden')

      new_item = $('<tr />').addClass('editable')
      new_item.attr('data-id', id)
      new_item.html(content)
      new_item_placeholder.before(new_item)

      @changeItemCount(1)
      @refresh()
    else
      new_item_placeholder.html(content)

    @fadeLoaded()

  edit: (id, content) =>
    @container.find('.editable').each (i, v) =>
      @cancelEdit($(v))
    @container.find('.new_item_placeholder').addClass('hidden')
    @container.find('.new_item_action').removeClass('hidden')

    editable = @container.find(".editable[data-id=#{id}]")
    editable.data('smart_listing_edit_backup', editable.html())
    editable.html(content)
    editable.addClass('info')

    @fadeLoaded()

  update: (id, success, content) =>
    editable = @container.find(".editable[data-id=#{id}]")
    if success
      editable.removeClass('info')
      editable.removeData('smart_listing_edit_backup')
      editable.html(content)

      @refresh()
    else
      editable.html(content)

    @fadeLoaded()
  
  destroy: (id, destroyed) =>
    # No need to do anything here, already handled by ajax:success handler

  remove: (id) =>
    editable = @container.find(".editable[data-id=#{id}]").first()
    editable.remove()
  
  update_list: (content, data) =>
    $.each data, (key, value) =>
      @container.data(key, value)

    @content.html(content)

    @refresh()
    @fadeLoaded()

$.fn.smart_listing = () ->
  map = $(this).map () ->
    if !$(this).data('smart-listing')
      $(this).data('smart-listing', new SmartListing($(this)))
    $(this).data('smart-listing')
  if map.length == 1
    map[0]
  else
    map

$.fn.handleSmartListingControls = () ->
  $(this).each () ->
    controls = $(this)
    smart_listing = $("##{controls.data('smart-listing')}")
    reset = controls.find(".reset")

    controls.submit ->
      # Merges smart list params with the form action url before submitting.
      # This preserves smart list settings (page, sorting etc.).

      prms = $.extend({}, smart_listing.smart_listing().params())
      if $(this).data('reset')
        prms[$(this).data('reset')] = null

      if $.rails.href(smart_listing)
        # If smart list has different target url than current one
        controls.attr('action', $.rails.href(smart_listing) + "?" + jQuery.param(prms))
      else
        controls.attr('action', "?" + jQuery.param(prms))

      smart_listing.trigger('ajax:before')
      true

    controls.find('input, select').change () ->
      unless $(this).data('observed') # do not submit controls form when changed field is observed (observing submits form by itself)
        controls.submit()

$.fn.handleSmartListingFilter = () ->
  filter = $(this)
  form = filter.closest('form')
  button = filter.find('button')
  icon = filter.find('i')
  field = filter.find('input')

  field.observeField(
    onFilled: ->
      icon.removeClass('glyphicon-search')
      icon.addClass('glyphicon-remove')
      button.removeClass('disabled')
    onEmpty: ->
      icon.addClass('glyphicon-search')
      icon.removeClass('glyphicon-remove')
      button.addClass('disabled')
    onChange: ->
      form.submit()
  )

  icon.click ->
    if field.val().length > 0
      field.val('')
      field.trigger('keydown')

$ ->
  $('.smart_listing').smart_listing()
  $('.smart_listing_controls').handleSmartListingControls()
  $('.smart_listing_controls .filter').handleSmartListingFilter()
