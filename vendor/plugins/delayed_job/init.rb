require File.dirname(__FILE__) + '/lib/delayed_job'
Delayed::Job.auto_scale = true
Delayed::Job.auto_scale_manager = :local