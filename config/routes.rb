ActionController::Routing::Routes.draw do |map|

  map.resources :grading_levels
  map.resources :ranking_levels, :collection => {:create_ranking_level=>[:get,:post], :edit_ranking_level=>[:get,:post], :update_ranking_level=>[:get,:post], :delete_ranking_level=>[:get,:post], :ranking_level_cancel=>[:get,:post], :change_priority=>[:get,:post]}
  map.resources :class_designations
  #map.resources :exam_reports, :collection => {:course_reports_index=>[:get,:post], :batch_reports_index=>[:get,:post]}
  map.resources :class_timings
  map.resources :subjects
  map.resources :attendances, :collection=>{:daily_register=>:get,:subject_wise_register=>:get}
  map.resources :employee_attendances
  map.resources :attendance_reports
  map.resources :cce_exam_categories
  map.resources :assessment_scores,:collection=>{:exam_fa_groups=>[:get],:observation_groups=>[:get]}
  map.resources :cce_settings,:collection=>{:basic=>[:get],:scholastic=>[:get],:co_scholastic=>[:get]}
  map.resources :scheduled_jobs,:except => [:show]
  map.resources :fa_groups,:collection=>{:assign_fa_groups=>[:get,:post],:new_fa_criteria=>[:get,:post],:create_fa_criteria=>[:get,:post],:edit_fa_criteria=>[:get,:post],:update_fa_criteria=>[:get,:post],:destroy_fa_criteria=>[:post],:reorder=>[:get,:post]}
  #  do |fa|
  #    fa.resources  :fa_criterias
  #  end
  map.resources :fa_criterias do |fa|
    fa.resources :descriptive_indicators do |desc|
      desc.resources :assessment_tools
    end
  end
  map.resources :observations do |obs|
    obs.resources :descriptive_indicators do |desc|
      desc.resources :assessment_tools
    end
  end
  map.resources :observation_groups,:member=>{:new_observation=>[:get,:post],:create_observation=>[:get,:post],:edit_observation=>[:get,:post],:update_observation=>[:get,:post],:destroy_observation=>[:post],:reorder=>[:get,:post]},:collection=>{:assign_courses=>[:get,:post],:set_observation_group=>[:get,:post]}
  map.resources :cce_weightages,:member=>{:assign_courses=>[:get,:post]},:collection=>{:assign_weightages=>[:get,:post]}
  map.resources :cce_grade_sets, :member=>{:new_grade=>[:get,:post],:edit_grade=>[:get,:post],:update_grade=>[:get,:post],:destroy_grade=>[:post]}

  map.feed 'courses/manage_course', :controller => 'courses' ,:action=>'manage_course'
  map.feed 'courses/manage_batches', :controller => 'courses' ,:action=>'manage_batches'
  map.resources :courses, :has_many => :batches, :collection => {:grouped_batches=>[:get,:post],:create_batch_group=>[:get,:post],:edit_batch_group=>[:get,:post],:update_batch_group=>[:get,:post],:delete_batch_group=>[:get,:post]}

  map.resources :batches, :collection=>{:batches_ajax=>[:get]} do |batch|
    batch.resources :exam_groups
    #batch.resources :additional_exam_groups
    batch.resources :elective_groups, :as => :electives
  end

  map.resources :exam_groups do |exam_group|
    exam_group.resources :exams, :member => { :save_scores => :post }
  end

#  map.resources :additional_exam_groups do |additional_exam_group|
#    additional_exam_group.resources :additional_exams , :member => { :save_additional_scores => :post }
#  end

  map.resources :timetables do |timetable|
    timetable.resources :timetable_entries
  end
  map.root :controller => 'user', :action => 'login'

  map.fa_scores 'assessment_scores/exam/:exam_id/fa_group/:fa_group_id', :controller=>'assessment_scores',:action=>'fa_scores'
  map.observation_scores 'assessment_scores/batch/:batch_id/observation_group/:observation_group_id', :controller=>'assessment_scores',:action=>'observation_scores'
  map.scheduled_task 'scheduled_jobs/:job_object/:job_type',:controller => "scheduled_jobs",:action => "index"
  map.scheduled_task_object 'scheduled_jobs/:job_object',:controller => "scheduled_jobs",:action => "index"


  #map.connect 'parts/:number', :controller => 'inventory', :action => 'sho
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action' 
  map.connect ':controller/:action/:id/:id2'
  map.connect ':controller/:action/:id.:format'

end