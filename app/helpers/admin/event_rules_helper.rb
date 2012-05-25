module Admin::EventRulesHelper

  def add_event_rule_button(f)
    fields = f.fields_for "new_event_rule", EventRule.new do |builder|
      render("form", :r => builder, :index => "new_event_rule")
    end
    button_tag 'Add New Rule', :class => "add_event_rule", "data-content" => "#{fields}"
  end

  def event_category_select(form)
    form.select :event_category, [
      ["Cloudfuji event", :cloudfuji_event_received],
      ["Lead attribute",   :lead_attribute_changed]
    ], {}, :class => "event_category_select"
  end

  def action_select(form)
    form.select :action, [
      ["change Lead score", :change_lead_score],
      ["send notification", :send_notification],
      ["add tag",           :add_tag],
      ["remove tag",        :remove_tag]
    ], {}, :class => "action_select"
  end

  # Generates divs with form field groups for event rules
  def fields_for_event_rule_group(object, subjects, field)
    subjects = [subjects].flatten
    content_tag(:div, :class => subjects.map {|s| "#{field}_#{s}" }.join(" ") << " #{field}_fields",
                      :style => (subjects.none? {|s| s == object.send(field) } ? "display: none;" : "")) do
      yield
    end
  end

  def event_fields_for(object, events, &content)
    fields_for_event_rule_group(object, events, 'event_category', &content)
  end

  def action_fields_for(object, actions, &content)
    fields_for_event_rule_group(object, actions, 'action', &content)
  end

  def lead_attributes
    Lead.attribute_names - %w(id deleted_at updated_at created_at)
  end

end
