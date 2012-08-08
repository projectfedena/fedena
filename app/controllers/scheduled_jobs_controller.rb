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
