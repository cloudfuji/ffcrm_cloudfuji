class UnknownEmailsController < ApplicationController
  before_filter :set_current_tab

  def index
    # Fetch all emails that don't belong to an
    # entity, and aren't in the 'ignored_emails' table.
    sql = %Q{SELECT * from emails 
      WHERE mediator_id IS NULL 
      AND NOT EXISTS (
        SELECT DISTINCT(email) FROM ignored_emails 
        WHERE email = emails.sent_from 
        OR email = emails.sent_to)} 
    @unknown_emails = Email.paginate_by_sql(sql, :page => params[:page])
    
    respond_with @unknown_emails
  end

  # Delete email and ignore all emails from this address
  def ignore
    @email = Email.find(params[:id])
    unless address = params[:email]
      if @email.direction == 'received'
        address = @email.sent_from
      elsif @email.direction == 'sent'
        address = @email.sent_to
      end
    end

    if address.present? 
      IgnoredEmail.create :email => address
      @email.destroy
      flash[:notice] = "All emails from #{address} will be ignored."
    else
      flash[:error] = "Could not determine whether this email was sent or received!"
    end
    redirect_to unknown_emails_path
  end

  # Create lead and attach this email to new lead
  def convert
    address = params[:email]

    if address.present?
      # Attach all orphaned emails that are from / to address
      @emails = Email.all(:conditions => [%Q{
        mediator_id IS NULL
        AND (emails.sent_from LIKE ?
          OR emails.sent_to LIKE ?)
      }, "%#{address}%", "%#{address}%"])

      lead = Lead.create :email      => address,
                         :first_name => address.split("@").first,
                         :last_name  => address.split("@").last,
                         :user       => current_user,
                         :emails     => @emails

      link_to_lead = ActionController::Base.helpers.link_to(lead_url(lead), lead_url(lead))
      flash[:notice] = "Created lead and attached email(s): #{link_to_lead}".html_safe
    else
      flash[:error] = "Must provide :email param!"
    end
    redirect_to unknown_emails_path

  end
end
