module Admin::LeadScoringHelper

  def add_lead_scoring_rule_button(f)
    fields = f.fields_for "new_lead_scoring_rule", LeadScoringRule.new(:points => 0) do |builder|
      render("form", :r => builder, :index => "new_lead_scoring_rule")
    end
    button_tag 'Add New Rule', :class => "add_lead_scoring_rule", "data-content" => "#{fields}"
  end

end
