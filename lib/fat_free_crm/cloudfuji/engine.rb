module FatFreeCRM
  module Cloudfuji
    class Engine < Rails::Engine
      config.to_prepare do
        # Add Lead Scoring tab
        begin
          FatFreeCRM::Tabs.admin << {
            :text => "Lead Scoring",
            :url => { :controller => "admin/lead_scoring" }
          }
        rescue TypeError
          puts "You must migrate your settings table."
        end
      end
    end
  end
end
