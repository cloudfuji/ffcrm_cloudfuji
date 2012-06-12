require 'fat_free_crm/mail_processor/base'

module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class EmailObserver < ::Cloudfuji::EventObserver
        include FatFreeCRM::Cloudfuji::EventObservers::Base

        # "email_delivered"
        # :message_headers  => "[[\"Received\", \"by luna.mailgun.net with SMTP mgrt 7313261; Tue, 20 Mar 2012 19:00:58 +0000\"], [\"Received\", \"from localhost.localdomain (ec2-23-20-14-40.compute-1.amazonaws.com [23.20.14.40]) by mxa.mailgun.org with ESMTP id 4f68d3e9.4ddcdf0-luna; Tue, 20 Mar 2012 19:00:57 -0000 (UTC)\"], [\"Date\", \"Tue, 20 Mar 2012 19:00:57 +0000\"], [\"From\", \"Sean Grove <sean@cloudfuji.com>\"], [\"Reply-To\", \"Cloudfuji Team <support@cloudfuji.com>\"], [\"Message-Id\", \"<4f68d3e9ad834_3c29377ea432615@ip-10-190-150-17.mail>\"], [\"X-Mailgun-Campaign-Id\", \"cloudfuji_buddies\"], [\"Repy-To\", \"support@cloudfuji.com\"], [\"To\", \"s+cfdemo@cloudfuji.com\"], [\"Subject\", \"Cloudfuji Beta: Thank you for your early support. Here's a gift for you.\"], [\"List-Unsubscribe\", \"<mailto:u+na6wcn3gmqzdszbsmrrdam3ghfstkzrxgbstgn3fgvtdgzjumvrgmyzgmm6tqnlkgetheplteuzeey3gmrsw23zfgqyge5ltnbus4zdpez2d2jjsietgipjrmi4a@email.cloudfuji.com>\"], [\"X-Mailgun-Sid\", \"WyI2NWQ4MSIsICJzK2NmZGVtb0BidXNoaS5kbyIsICIxYjgiXQ==\"], [\"Sender\", \"sean=cloudfuji.com@cloudfuji.com\"]]"
        # :message_id       =>"<4f68d3e9ad834_3c29377ea432615@ip-10-190-150-17.mail>"
        # :recipient        => "s+cfdemo@cloudfuji.com"
        # :domain           => "cloudfuji.com"
        # :custom_variables => nil
        # :human            =>"Mail to s+cfdemo@cloudfuji.com successfully delievered."}}
        def email_delivered
          message  = ""
          message += "Email delivered to #{email}"
          message += " in email campaign '#{campaign.titleize}'" if campaign

          note_email_activity( message.strip )
        end

        # "email_opened"
        # :recipient=>"s+cfdemo@cloudfuji.com"
        # :domain=>"cloudfuji.com"
        # :campaign_id=>"cloudfuji_buddies"
        # :campaign_name=>"Cloudfuji Buddies"
        # :tag=>nil
        # :mailing_list=>nil
        # :custom_variables=>nil
        def email_opened
          message  = ""
          message += "Email opened by #{email}"
          message += " in email campaign '#{campaign.titleize}'" if campaign

          note_email_activity( message.strip )
        end

        # :event=>"clicked"
        # :recipient=>"s+cfdemo@cloudfuji.com"
        # :domain=>"cloudfuji.com"
        # :campaign_id=>"cloudfuji_buddies"
        # :campaign_name=>"Cloudfuji Buddies"
        # :tag=>nil
        # :mailing_list=>nil
        # :custom_variables=>nil
        # :url=>"https://cloudfuji.com/cas/invite/?invitation_token=8hswc7kqhPys6FsUJ1Nm&service=https://cloudfuji.com/users/service&redirect=https://cloudfuji.com/apps/new?app=fat_free_crm&src=icon"
        # :human=>"s+cfdemo@cloudfuji.com clicked on link in Cloudfuji Buddies to https://cloudfuji.com/cas/invite/?invitation_token=8hswc7kqhPys6FsUJ1Nm&service=https://cloudfuji.com/users/service&redirect=https://cloudfuji.com/apps/new?app=fat_free_crm&src=icon"}
        def email_clicked
          message = "#{email} clicked #{data['url']}"
          message += "in email campaign '#{campaign.titleize}'" if campaign

          note_email_activity(message)
        end


        def email_subscribed
          note_email_activity("#{email} subscribed to a mailing list")
        end

        def email_received
          user = find_user_by_account
          return unless user
          lead = Lead.find_by_email(data['from'])
          create_email_from_data(
            :direction => 'received',
            :mediator  => lead,
            :user      => user
          )
        end

        def email_sent
          user = find_user_by_account
          return unless user
          # Find first Lead from 'to' email addresses
          lead = data['to'].to_s.split(";").detect do |email|
            lead = Lead.find_by_email(email)
          end
          create_email_from_data(
            :direction => 'sent',
            :mediator  => lead,
            :user      => user
          )
        end

        private

        def note_email_activity(message)
          subject = find_or_create_activity_subject!
          puts "Found subject: #{subject.inspect}"

          subject.versions.create! :event => message
        end

        # Temp workarounds until umi delivers events properly
        # Good example of the necessity of deep-schema enforcement for events
        def headers
          begin
            JSON(data['message_headers'])
          rescue => e
            return []
          end
        end

        def custom_variables
          JSON(data['custom_variables'])
        end

        def campaign
          campaign   = data['campaign_id'] || data['campaign_name']
          campaign ||= headers.select{|key, value| key == "X-Mailgun-Campaign-Id"}.try(:first).try(:last) unless headers.empty?
          campaign
        end

        def find_user_by_account
          user = User.find_by_email(data['account'])
          puts "No User found by email #{data['account']}" unless user
          user
        end

        def create_email_from_data(options)
          mail = Mail.new(data['rfc822'])
          text_body = FatFreeCRM::MailProcessor::Base.new.send(:plain_text_body, mail)
           
          # Remove ID hashes from emails (e.g. ...+23423fce32d@...)
          # This is important so that addresses like 
          # reply+****@reply.github.com can be ignored.
          to_address = data['to'].gsub(/\+[^@]+/, '')
          from_address = data['from'].gsub(/\+[^@]+/, '')

          Email.create({
            :imap_message_id => data['uid'],
            :sent_from       => from_address,
            :sent_to         => to_address,
            :cc              => data['cc'],
            :subject         => data['subject'],
            :body            => text_body,
            :sent_at         => data['date']
          }.merge(options))
        end
      end
    end
  end
end
