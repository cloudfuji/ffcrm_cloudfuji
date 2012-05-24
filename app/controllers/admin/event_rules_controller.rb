class Admin::EventRulesController < Admin::ApplicationController
  before_filter :require_user
  before_filter "set_current_tab('admin/event_rules')", :only => [ :index, :update ]

  # GET /admin/event_rules
  #----------------------------------------------------------------------------
  def index
    @event_rules = EventRule.all
    @event_rules << EventRule.new if @event_rules.empty?

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  # PUT /admin/event_rules
  #----------------------------------------------------------------------------
  def update
    # Create rules without ids,
    # destroy rules with '_destroy' param,
    # update rules with ids
    @event_rules = []
    params[:event_rules].each do |index, data|
      if data["id"].blank?
        @event_rules << EventRule.create(data)
      else
        if rule = EventRule.find_by_id(data["id"])
          if data["_destroy"]
            rule.destroy
          else
            rule.update_attributes data
            @event_rules << rule
          end
        end
      end
    end

    if @event_rules.all?(&:valid?)
      flash[:notice] = "All rules were saved successfully."
    else
      flash[:error] = render_to_string(:partial => "errors").html_safe
    end

    respond_to do |format|
      format.html { render "index" }
    end
  end

end
