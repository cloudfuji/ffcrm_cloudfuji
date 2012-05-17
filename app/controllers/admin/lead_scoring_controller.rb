class Admin::LeadScoringController < Admin::ApplicationController
  before_filter :require_user
  before_filter "set_current_tab('admin/lead_scoring')", :only => [ :index, :update ]

  # GET /admin/lead_scoring
  #----------------------------------------------------------------------------
  def index
    @lead_scoring_rules = LeadScoringRule.all
    @lead_scoring_rules << LeadScoringRule.new if @lead_scoring_rules.empty?

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  # PUT /admin/lead_scoring
  #----------------------------------------------------------------------------
  def update
    # Create rules without ids,
    # destroy rules with '_destroy' param,
    # update rules with ids
    @lead_scoring_rules = []
    params[:lead_scoring_rules].each do |index, data|
      if data["id"].blank?
        @lead_scoring_rules << LeadScoringRule.create(data)
      else
        if rule = LeadScoringRule.find_by_id(data["id"])
          if data["_destroy"]
            rule.destroy
          else
            rule.update_attributes data
            @lead_scoring_rules << rule
          end
        end
      end
    end

    if @lead_scoring_rules.all?(&:valid?)
      flash[:notice] = "All rules were saved successfully."
    else
      flash[:error] = render_to_string(:partial => "errors").html_safe
    end

    respond_to do |format|
      format.html { render "index" }
    end
  end

end
