module Admin::EventRulesHelper

  def add_event_rule_button(f)
    fields = f.fields_for "new_event_rule", EventRule.new(:points => 0) do |builder|
      render("form", :r => builder, :index => "new_event_rule")
    end
    button_tag 'Add New Rule', :class => "add_event_rule", "data-content" => "#{fields}"
  end

end
