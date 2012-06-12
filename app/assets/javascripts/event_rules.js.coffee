(($) ->
  class @EventRules
    constructor: (@templates = {}) ->

    add_fields: (button, content) ->
      new_id = new Date().getTime()
      regexp = new RegExp('new_event_rule', 'g')
      $('ul#event_rules').append(content.replace(regexp, new_id))
      # Setup event autocomplete for new field
      this.cloudfuji_event_autocomplete("input#event_rules_#{new_id}_cloudfuji_event")

    remove_fields: (button) ->
      container = $(button).closest('li.event_rule')
      index = container.data('index')
      # If rule has no id, just remove
      if $("#event_rules_#{index}_id").length == 0
        container.remove()
      else
        # If rule has an id, mark container as hidden and add _destroy field
        container.hide()
        container.append($("<input type='text' name='event_rules[#{index}][_destroy]' value='yes'>"))

    cloudfuji_event_autocomplete: (selector = 'input.cloudfuji_event') ->
      $(selector).autocomplete({source: observed_cloudfuji_events, minLength: 0})
      # Show all events on focus, if input is empty
      $(selector).focus ->
        $(this).autocomplete "search", "" if $(this).val() == ""

    show_field_group: (select, group_name, key) ->
      # Hide all fields, then show the selected field group
      container = $(select).closest('li.event_rule')
      container.find(".#{group_name}_fields").hide()
      container.find(".#{group_name}_#{key}").show()

  $(document).ready ->
    event_rules = new EventRules()
    # Initialize autocomplete for events
    event_rules.cloudfuji_event_autocomplete() if observed_cloudfuji_events?

    $("button.add_event_rule").live "click", ->
      event_rules.add_fields this, $(this).data("content")
      false

    $(".remove_event_rule").live "click", ->
      event_rules.remove_fields this
      false

    $('.event_category_select').live "change", ->
      event_rules.show_field_group this, 'event_category', $(this).val()

      # Set 'cloudfuji_event' to 'page_loaded' if event category is page_loaded.
      if $(this).val() == "page_loaded"
        index = $(this).closest('li.event_rule').data('index')
        $("#event_rules_#{index}_cloudfuji_event").val('page_loaded')

    $('.action_select').live "change", ->
      event_rules.show_field_group this, 'action', $(this).val()


) jQuery
