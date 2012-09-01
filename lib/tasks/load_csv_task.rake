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

namespace :db do

  desc "load user data from csv"
  task :load_csv_task  => :environment do

    require 'fastercsv'

    FasterCSV.foreach("excel.csv") do |row|

      log=Logger.new("log/csv.log")
      log.debug "************** conversion started at #{Date.today}********************"

      s = Student.new(
        :admission_no => row[0],
        :class_roll_no => row[1],     # class roll no.
        :admission_date => row[2],

        :first_name => row[3],
        :middle_name => row[4],
        :last_name => row[5],

        :batch_id => row[6],
        :date_of_birth => row[7],
        :gender => row[8],
        :blood_group => row[9],
        :birth_place => row[10],
        :nationality_id => row[11],
        :language => row[12],
        :religion => row[13],
        :student_category_id => row[14],

        :address_line1 => row[15],
        :address_line2 => row[16],
        :city => row[17],
        :state => row[18],
        :pin_code => row[19],
        :country_id => row[20],

        :phone1 => row[21],
        :phone2 => row[22],
        :email => row[23]

      )

       if s.save

      else
        log.debug "first_name    => #{s.first_name}" unless s.first_name.blank?
        log.debug "Addmission_n0 => #{s.admission_no}" unless s.admission_no.blank?
        log.debug "batch_name    => #{s.batch_id}" unless s.batch_id.blank?
        log.debug "error_name    => #{s.errors.full_messages}"
        log.debug "**************************************************************"
        puts s.errors.full_messages
      end

    end
  end
end