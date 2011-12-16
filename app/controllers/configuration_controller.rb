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

class ConfigurationController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  FILE_EXTENSIONS = [".jpg",".jpeg",".png"]#,".gif",".png"]
  FILE_MAXIMUM_SIZE_FOR_FILE=1048576

  def settings
    @config = Configuration.get_multiple_configs_as_hash ['InstitutionName', 'InstitutionAddress', 'InstitutionPhoneNo', \
        'StudentAttendanceType', 'CurrencyType', 'ExamResultType', 'AdmissionNumberAutoIncrement','EmployeeNumberAutoIncrement', \
        'NetworkState','Locale','FinancialYearStartDate','FinancialYearEndDate']

    if request.post?

      unless params[:upload].nil?
        @temp_file=params[:upload][:datafile]
        unless FILE_EXTENSIONS.include?(File.extname(@temp_file.original_filename).downcase)
          flash[:notice] = "#{t('flash1')}"
          redirect_to :action => "settings"  and return
        end
        if @temp_file.size > FILE_MAXIMUM_SIZE_FOR_FILE
          flash[:notice] = "#{t('flash2')}"
          redirect_to :action => "settings" and return
        end
      end
    
      Configuration.set_config_values(params[:configuration])
      Configuration.save_institution_logo(params[:upload]) unless params[:upload].nil?
      session[:language] = nil unless session[:language].nil?
      @current_user.clear_menu_cache
      flash[:notice] = "#{t('flash_msg8')}"
      redirect_to :action => "settings"  and return
    end
  end
end