module FatFreeCRM
  module Cloudfuji
    class CloudfujiViewHooks < ::FatFreeCRM::Callback::Base

      # Add lead scoring to summary on lead show page
      def show_lead_sidebar_bottom(view, context)
        view.render(:partial => 'leads/sidebar_show_lead_scoring', :locals => {:lead => context[:lead]})
      end

    end
  end
end
