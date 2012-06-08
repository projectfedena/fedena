#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class UserNotifier < ActionMailer::Base
  def forgot_password(user,current_url)
    setup_email(user,current_url)
    @subject    += 'Reset Password'
    @body[:url]  =  current_url+"/user/reset_password/#{user.reset_password_code}"
  end

  protected
    def setup_email(user, current_url)
      @recipients  = "#{user.email}"
      admin_email = User.find_by_username('admin').email
      admin_email ||= "noreply@#{get_domain(current_url)}"
      @from        = admin_email
      @subject     = " "
      @sent_on     = Time.now
      @body[:user] = user
    end

    def get_domain(current_url)
      url_parts = current_url.split("://").last.split('.')
      url_parts[(url_parts.length - 2) .. (url_parts.length - 1)].join('.')
    end
end