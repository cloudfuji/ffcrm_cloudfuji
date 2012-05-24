module FatFreeCRM
  module Cloudfuji
    class Engine < Rails::Engine
      config.to_prepare do
        require 'fat_free_crm/cloudfuji/view_hooks'

        # Add Event Rules tab
        begin
          unless FatFreeCRM::Tabs.admin.any? {|t| t[:text] == "Event Rules" }
            FatFreeCRM::Tabs.admin << {
            :text => "Event Rules",
            :url => { :controller => "admin/event_rules" }
          }
          end
        rescue TypeError
          puts "You must migrate your settings table."
        end
      end
    end
  end
end
