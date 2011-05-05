class UserNotifier < ActionMailer::Base
  def forgot_password(user)
    setup_email(user)
    @subject    += 'Reset Password'
    @body[:url]  = "http://demo.projectfedena.org/user/reset_password/#{user.reset_password_code}"
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "admin@fedena.com"
      @subject     = "[fedena.com] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end