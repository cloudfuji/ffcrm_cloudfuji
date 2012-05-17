module FatFreeCRM
  module Cloudfuji
    class Engine < Rails::Engine
      config.to_prepare do
        require 'fat_free_crm/cloudfuji/view_hooks'

        # Add Lead Scoring tab
        begin
          unless FatFreeCRM::Tabs.admin.any? {|t| t[:text] == "Lead Scoring" }
            FatFreeCRM::Tabs.admin << {
            :text => "Lead Scoring",
            :url => { :controller => "admin/lead_scoring" }
          }
          end
        rescue TypeError
          puts "You must migrate your settings table."
        end
      end
    end
  end
end
