module FatFreeCRM
  module Cloudfuji
    class Engine < Rails::Engine
      config.before_initialize do
        # Register observers to fire Cloudfuji events
        (config.active_record.observers ||= []) << :cloudfuji_lead_observer
      end
    
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

          unless FatFreeCRM::Tabs.main.any? {|t| t[:text] == "Unknown Emails" }
            FatFreeCRM::Tabs.main << {
              :text => "Unknown Emails",
              :url => { :controller => "unknown_emails" }
            }
          end
        rescue TypeError
          puts "You must migrate your settings table."
        end
      end
    end
  end
end
