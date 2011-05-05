class FedenaMailer < ActionMailer::Base
  def email(sender,recipients, subject, message)
    @bcc = recipients
    @recipients = 'noreply@fedena.com'
    @from = sender
    @subject = subject
    @sent_on = Time.now
    @body['message'] = message
  end
end
