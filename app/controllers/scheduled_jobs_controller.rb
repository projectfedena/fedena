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

class ScheduledJobsController < ApplicationController
  def index
    @jobs = Delayed::Job.all
    @all_jobs = @jobs.dup
    unless params[:job_object].nil? and params[:job_type].nil?
      @jobs = []
      unless params[:job_type].nil?
        @job_type = params[:job_object].to_s+"/"+params[:job_type].to_s
        @all_jobs.each do|j|
          h = j.handler
          unless h.nil?
            obj = j.payload_object.class.name
            type = j.payload_object.job_type
            j_type = "#{obj}/#{type}"
            if j_type == @job_type
              @jobs.push j
            end
          end
        end
      else
        @job_type = params[:job_object].to_s
        @all_jobs.each do|j|
          h = j.handler
          unless h.nil?
            obj = j.payload_object.class.name
            if obj == @job_type
              @jobs.push j
            end
          end
        end
      end
    end
  end

end
