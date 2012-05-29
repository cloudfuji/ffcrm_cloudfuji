module FatFreeCRM
  module Cloudfuji
    class CloudfujiViewHooks < ::FatFreeCRM::Callback::Base

      # Add lead scoring to summary on lead show page
      def show_lead_sidebar_bottom(view, context)
        view.render(:partial => 'leads/sidebar_show_lead_scoring', :locals => context)
      end

      def lead_top_section_bottom(view, context)
        view.render(:partial => 'leads/top_section_ido_id', :locals => context)
      end

    end
  end
end
