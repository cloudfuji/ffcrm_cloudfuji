(($) ->
  class @LeadScoring
    constructor: (@templates = {}) ->

    add_fields: (button, content) ->
      new_id = new Date().getTime()
      regexp = new RegExp('new_lead_scoring_rule', 'g')
      $('ul#lead_scoring_rules').append(content.replace(regexp, new_id))

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

  $(document).ready ->
    lead_scoring = new LeadScoring()

    $("button.add_lead_scoring_rule").live "click", ->
      lead_scoring.add_fields this, $(this).data("content")
      false

    $(".remove_lead_scoring_rule").live "click", ->
      lead_scoring.remove_fields this
      false

) jQuery