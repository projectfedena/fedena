ActionController::Routing::Routes.draw do |map|

  map.resources :grading_levels
  map.resources :ranking_levels, :collection => {:create_ranking_level=>[:get,:post], :edit_ranking_level=>[:get,:post], :update_ranking_level=>[:get,:post], :delete_ranking_level=>[:get,:post], :change_priority=>[:get,:post]}
  map.resources :class_designations
  map.resources :exam_reports, :collection => {:course_reports_index=>[:get,:post], :batch_reports_index=>[:get,:post]}
  map.resources :class_timings
  map.resources :subjects
  map.resources :attendances, :collection=>{:daily_register=>:get,:subject_wise_register=>:get}
  map.resources :employee_attendances
  map.resources :attendance_reports

  map.feed 'courses/manage_course', :controller => 'courses' ,:action=>'manage_course'
  map.feed 'courses/manage_batches', :controller => 'courses' ,:action=>'manage_batches'
  map.resources :courses, :has_many => :batches, :collection => {:grouped_batches=>[:get,:post],:create_batch_group=>[:get,:post],:edit_batch_group=>[:get,:post],:update_batch_group=>[:get,:post],:delete_batch_group=>[:get,:post]}

  map.resources :batches do |batch|
    batch.resources :exam_groups
    batch.resources :additional_exam_groups
    batch.resources :elective_groups, :as => :electives
  end

  map.resources :exam_groups do |exam_group|
    exam_group.resources :exams, :member => { :save_scores => :post }
  end

  map.resources :additional_exam_groups do |additional_exam_group|
    additional_exam_group.resources :additional_exams , :member => { :save_additional_scores => :post }
  end

  map.resources :timetables do |timetable|
    timetable.resources :timetable_entries
  end
  map.root :controller => 'user', :action => 'login'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id/:id2'
  map.connect ':controller/:action/:id.:format'

end