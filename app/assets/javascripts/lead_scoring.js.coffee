(($) ->
  class @LeadScoring
    constructor: (@templates = {}) ->

    add_fields: (button, content) ->
      new_id = new Date().getTime()
      regexp = new RegExp('new_lead_scoring_rule', 'g')
      $('ul#lead_scoring_rules').append(content.replace(regexp, new_id))
      # Setup event autocomplete for new field
      this.event_autocomplete('input#lead_scoring_rules_'+new_id+'_event')

    remove_fields: (button) ->
      container = $(button).closest('li.lead_scoring_rule')
      index = container.data('index')
      # If rule has no id, just remove
      if $("#lead_scoring_rules_"+index+"_id").length == 0
        container.remove()
      else
        # If rule has an id, mark container as hidden and add _destroy field
        container.hide()
        container.append($('<input type="text" name="lead_scoring_rules['+index+'][_destroy]" value="yes">'))

    event_autocomplete: (selector = 'input.lead_scoring_event') ->
      $(selector).autocomplete({source: observed_cloudfuji_events, minLength: 0})
      # Show all events on focus, if input is empty
      $(selector).focus ->
        $(this).autocomplete "search", "" if $(this).val() == ""

  $(document).ready ->
    lead_scoring = new LeadScoring()
    # Initialize autocomplete for events
    lead_scoring.event_autocomplete()

    $("button.add_lead_scoring_rule").live "click", ->
      lead_scoring.add_fields this, $(this).data("content")
      false

    $(".remove_lead_scoring_rule").live "click", ->
      lead_scoring.remove_fields this
      false

) jQuery
