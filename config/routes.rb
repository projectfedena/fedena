Fedena::Application.routes.draw do
  resources :grading_levels
  resources :ranking_levels, :collection => {:create_ranking_level=>[:get,:post], :edit_ranking_level=>[:get,:post], :update_ranking_level=>[:get,:post], :delete_ranking_level=>[:get,:post], :ranking_level_cancel=>[:get,:post], :change_priority=>[:get,:post]}
  resources :class_designations
  #resources :exam_reports, :collection => {:course_reports_index=>[:get,:post], :batch_reports_index=>[:get,:post]}
  resources :class_timings
  resources :subjects
  resources :attendances, :collection=>{:daily_register=>:get,:subject_wise_register=>:get}
  resources :employee_attendances
  resources :attendance_reports
  resources :cce_exam_categories
  resources :assessment_scores,:collection=>{:exam_fa_groups=>[:get],:observation_groups=>[:get]}
  resources :cce_settings,:collection=>{:basic=>[:get],:scholastic=>[:get],:co_scholastic=>[:get]}
  resources :scheduled_jobs,:except => [:show]
  resources :fa_groups,:collection=>{:assign_fa_groups=>[:get,:post],:new_fa_criteria=>[:get,:post],:create_fa_criteria=>[:get,:post],:edit_fa_criteria=>[:get,:post],:update_fa_criteria=>[:get,:post],:destroy_fa_criteria=>[:post],:reorder=>[:get,:post]}
  #  do |fa|
  #    fa.resources  :fa_criterias
  #  end
  resources :fa_criterias do |fa|
    resources :descriptive_indicators do |desc|
      resources :assessment_tools
    end
  end
  resources :observations do |obs|
    resources :descriptive_indicators do |desc|
      resources :assessment_tools
    end
  end
  resources :observation_groups,:member=>{:new_observation=>[:get,:post],:create_observation=>[:get,:post],:edit_observation=>[:get,:post],:update_observation=>[:get,:post],:destroy_observation=>[:post],:reorder=>[:get,:post]},:collection=>{:assign_courses=>[:get,:post],:set_observation_group=>[:get,:post]}
  resources :cce_weightages,:member=>{:assign_courses=>[:get,:post]},:collection=>{:assign_weightages=>[:get,:post]}
  resources :cce_grade_sets, :member=>{:new_grade=>[:get,:post],:edit_grade=>[:get,:post],:update_grade=>[:get,:post],:destroy_grade=>[:post]}

  # feed 'courses/manage_course', :controller => 'courses' ,:action=>'manage_course'
  # feed 'courses/manage_batches', :controller => 'courses' ,:action=>'manage_batches'
  resources :courses, :has_many => :batches, :collection => {:grouped_batches=>[:get,:post],:create_batch_group=>[:get,:post],:edit_batch_group=>[:get,:post],:update_batch_group=>[:get,:post],:delete_batch_group=>[:get,:post],:assign_subject_amount => [:get,:post],:edit_subject_amount => [:get,:post],:destroy_subject_amount => [:get,:post]}

  resources :batches, :collection=>{:batches_ajax=>[:get]} do |batch|
    resources :exam_groups
    #batch.resources :additional_exam_groups
    resources :elective_groups, :as => :electives
  end

  resources :exam_groups do |exam_group|
    resources :exams, :member => { :save_scores => :post }
  end

  #  resources :additional_exam_groups do |additional_exam_group|
  #    additional_exam_group.resources :additional_exams , :member => { :save_additional_scores => :post }
  #  end

  resources :timetables do |timetable|
    resources :timetable_entries
  end
  root :controller => 'user', :action => 'login'

  # fa_scores 'assessment_scores/exam/:exam_id/fa_group/:fa_group_id', :controller=>'assessment_scores',:action=>'fa_scores'
  # observation_scores 'assessment_scores/batch/:batch_id/observation_group/:observation_group_id', :controller=>'assessment_scores',:action=>'observation_scores'
  # scheduled_task 'scheduled_jobs/:job_object/:job_type',:controller => "scheduled_jobs",:action => "index"
  # scheduled_task_object 'scheduled_jobs/:job_object',:controller => "scheduled_jobs",:action => "index"


  #connect 'parts/:number', :controller => 'inventory', :action => 'sho
  # connect ':controller/:action/:id'
  # connect ':controller/:action'
  # connect ':controller/:action/:id/:id2'
  # connect ':controller/:action/:id.:format'
end
