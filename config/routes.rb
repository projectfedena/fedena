ActionController::Routing::Routes.draw do |map|

  map.resources :grading_levels
  map.resources :class_timings
  map.resources :subjects
  map.resources :attendances
  map.resources :employee_attendances
  map.resources :attendance_reports

  map.feed 'courses/manage_course', :controller => 'courses' ,:action=>'manage_course'
  map.feed 'courses/manage_batches', :controller => 'courses' ,:action=>'manage_batches'
  map.resources :courses, :has_many => :batches

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

  map.root :controller => 'user', :action => 'login'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id/:id2'
  map.connect ':controller/:action/:id.:format'

end