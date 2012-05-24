(($) ->
  class @EventRules
    constructor: (@templates = {}) ->

    add_fields: (button, content) ->
      new_id = new Date().getTime()
      regexp = new RegExp('new_event_rule', 'g')
      $('ul#event_rules').append(content.replace(regexp, new_id))
      # Setup event autocomplete for new field
      this.event_autocomplete('input#event_rules_'+new_id+'_event')

    remove_fields: (button) ->
      container = $(button).closest('li.event_rule')
      index = container.data('index')
      # If rule has no id, just remove
      if $("#event_rules_"+index+"_id").length == 0
        container.remove()
      else
        # If rule has an id, mark container as hidden and add _destroy field
        container.hide()
        container.append($('<input type="text" name="event_rules['+index+'][_destroy]" value="yes">'))

    event_autocomplete: (selector = 'input.event_rules_event') ->
      $(selector).autocomplete({source: observed_cloudfuji_events, minLength: 0})
      # Show all events on focus, if input is empty
      $(selector).focus ->
        $(this).autocomplete "search", "" if $(this).val() == ""

  $(document).ready ->
    event_rules = new EventRules()
    # Initialize autocomplete for events
    event_rules.event_autocomplete()

    $("button.add_event_rule").live "click", ->
      event_rules.add_fields this, $(this).data("content")
      false

    $(".remove_event_rule").live "click", ->
      event_rules.remove_fields this
      false

) jQuery
