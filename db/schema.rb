# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110812084631) do

  create_table "additional_exam_groups", :force => true do |t|
    t.string  "name"
    t.integer "batch_id"
    t.string  "exam_type"
    t.boolean "is_published",     :default => false
    t.boolean "result_published", :default => false
    t.string  "students_list"
    t.date    "exam_date"
  end

  create_table "additional_exam_scores", :force => true do |t|
    t.integer  "student_id"
    t.integer  "additional_exam_id"
    t.decimal  "marks",              :precision => 7, :scale => 2
    t.integer  "grading_level_id"
    t.string   "remarks"
    t.boolean  "is_failed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "additional_exams", :force => true do |t|
    t.integer  "additional_exam_group_id"
    t.integer  "subject_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "maximum_marks"
    t.integer  "minimum_marks"
    t.integer  "grading_level_id"
    t.integer  "weightage",                :default => 0
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "additional_fields", :force => true do |t|
    t.string  "name"
    t.boolean "status"
  end

  create_table "apply_leaves", :force => true do |t|
    t.integer "employee_id"
    t.integer "employee_leave_types_id"
    t.boolean "is_half_day"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "reason"
    t.boolean "approved",                :default => false
    t.boolean "viewed_by_manager",       :default => false
    t.string  "manager_remark"
  end

  create_table "archived_employee_additional_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "additional_field_id"
    t.string  "additional_info"
  end

  create_table "archived_employee_bank_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "bank_field_id"
    t.string  "bank_info"
  end

  create_table "archived_employee_salary_structures", :force => true do |t|
    t.integer "employee_id"
    t.integer "payroll_category_id"
    t.string  "amount"
  end

  create_table "archived_employees", :force => true do |t|
    t.integer  "employee_category_id"
    t.string   "employee_number"
    t.date     "joining_date"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.boolean  "gender"
    t.string   "job_title"
    t.integer  "employee_position_id"
    t.integer  "employee_department_id"
    t.integer  "reporting_manager_id"
    t.integer  "employee_grade_id"
    t.string   "qualification"
    t.text     "experience_detail"
    t.integer  "experience_year"
    t.integer  "experience_month"
    t.boolean  "status"
    t.string   "status_description"
    t.date     "date_of_birth"
    t.string   "marital_status"
    t.integer  "children_count"
    t.string   "father_name"
    t.string   "mother_name"
    t.string   "husband_name"
    t.string   "blood_group"
    t.integer  "nationality_id"
    t.string   "home_address_line1"
    t.string   "home_address_line2"
    t.string   "home_city"
    t.string   "home_state"
    t.integer  "home_country_id"
    t.string   "home_pin_code"
    t.string   "office_address_line1"
    t.string   "office_address_line2"
    t.string   "office_city"
    t.string   "office_state"
    t.integer  "office_country_id"
    t.string   "office_pin_code"
    t.string   "office_phone1"
    t.string   "office_phone2"
    t.string   "mobile_phone"
    t.string   "home_phone"
    t.string   "email"
    t.string   "fax"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.binary   "photo_data",             :limit => 16777215
    t.integer  "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "former_id"
  end

  create_table "archived_exam_scores", :force => true do |t|
    t.integer  "student_id"
    t.integer  "exam_id"
    t.decimal  "marks",            :precision => 7, :scale => 2
    t.integer  "grading_level_id"
    t.string   "remarks"
    t.boolean  "is_failed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "archived_exam_scores", ["student_id", "exam_id"], :name => "index_archived_exam_scores_on_student_id_and_exam_id"

  create_table "archived_guardians", :force => true do |t|
    t.integer  "ward_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "relation"
    t.string   "email"
    t.string   "office_phone1"
    t.string   "office_phone2"
    t.string   "mobile_phone"
    t.string   "office_address_line1"
    t.string   "office_address_line2"
    t.string   "city"
    t.string   "state"
    t.integer  "country_id"
    t.date     "dob"
    t.string   "occupation"
    t.string   "income"
    t.string   "education"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archived_students", :force => true do |t|
    t.string   "admission_no"
    t.string   "class_roll_no"
    t.date     "admission_date"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.integer  "batch_id"
    t.date     "date_of_birth"
    t.string   "gender"
    t.string   "blood_group"
    t.string   "birth_place"
    t.integer  "nationality_id"
    t.string   "language"
    t.string   "religion"
    t.integer  "student_category_id"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "city"
    t.string   "state"
    t.string   "pin_code"
    t.integer  "country_id"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "email"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.binary   "photo_data",           :limit => 16777215
    t.integer  "photo_file_size"
    t.string   "status_description"
    t.boolean  "is_active",                                :default => true
    t.boolean  "is_deleted",                               :default => false
    t.integer  "immediate_contact_id"
    t.boolean  "is_sms_enabled",                           :default => true
    t.string   "former_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_file_size"
  end

  create_table "assets", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "amount"
    t.boolean  "is_inactive", :default => false
    t.boolean  "is_deleted",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attendances", :force => true do |t|
    t.integer "student_id"
    t.integer "period_table_entry_id"
    t.boolean "forenoon",              :default => false
    t.boolean "afternoon",             :default => false
    t.string  "reason"
  end

  create_table "bank_fields", :force => true do |t|
    t.string  "name"
    t.boolean "status"
  end

  create_table "batch_events", :force => true do |t|
    t.integer  "event_id"
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "batch_events", ["batch_id"], :name => "index_batch_events_on_batch_id"

  create_table "batch_students", :id => false, :force => true do |t|
    t.integer "student_id"
    t.integer "batch_id"
  end

  add_index "batch_students", ["batch_id", "student_id"], :name => "index_batch_students_on_batch_id_and_student_id"

  create_table "batches", :force => true do |t|
    t.string   "name"
    t.integer  "course_id"
    t.string   "employee_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_active",   :default => true
    t.boolean  "is_deleted",  :default => false
  end

  add_index "batches", ["is_deleted", "is_active"], :name => "index_batches_on_is_deleted_and_is_active"

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "class_timings", :force => true do |t|
    t.integer "batch_id"
    t.string  "name"
    t.time    "start_time"
    t.time    "end_time"
    t.boolean "is_break"
  end

  add_index "class_timings", ["batch_id", "start_time", "end_time"], :name => "index_class_timings_on_batch_id_and_start_time_and_end_time"

  create_table "configurations", :force => true do |t|
    t.string "config_key"
    t.string "config_value"
  end

  add_index "configurations", ["config_key"], :name => "index_configurations_on_config_key"
  add_index "configurations", ["config_value"], :name => "index_configurations_on_config_value"

  create_table "countries", :force => true do |t|
    t.string "name"
  end

  create_table "courses", :force => true do |t|
    t.string   "course_name"
    t.string   "code"
    t.string   "section_name"
    t.boolean  "is_deleted",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "elective_groups", :force => true do |t|
    t.string   "name"
    t.integer  "batch_id"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "electives", :force => true do |t|
    t.integer  "elective_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_additional_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "additional_field_id"
    t.string  "additional_info"
  end

  create_table "employee_attendances", :force => true do |t|
    t.date    "attendance_date"
    t.integer "employee_id"
    t.integer "employee_leave_type_id"
    t.string  "reason"
    t.boolean "is_half_day"
  end

  create_table "employee_bank_details", :force => true do |t|
    t.integer "employee_id"
    t.integer "bank_field_id"
    t.string  "bank_info"
  end

  create_table "employee_categories", :force => true do |t|
    t.string  "name"
    t.string  "prefix"
    t.boolean "status"
  end

  create_table "employee_department_events", :force => true do |t|
    t.integer  "event_id"
    t.integer  "employee_department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_departments", :force => true do |t|
    t.string  "code"
    t.string  "name"
    t.boolean "status"
  end

  create_table "employee_grades", :force => true do |t|
    t.string  "name"
    t.integer "priority"
    t.boolean "status"
    t.integer "max_hours_day"
    t.integer "max_hours_week"
  end

  create_table "employee_leave_types", :force => true do |t|
    t.string  "name"
    t.string  "code"
    t.boolean "status"
    t.boolean "carry_forward",   :default => false
    t.string  "max_leave_count"
  end

  create_table "employee_leaves", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "employee_leave_type_id"
    t.decimal  "leave_count",            :precision => 5, :scale => 1, :default => 0.0
    t.decimal  "leave_taken",            :precision => 5, :scale => 1, :default => 0.0
    t.date     "reset_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_positions", :force => true do |t|
    t.string  "name"
    t.integer "employee_category_id"
    t.boolean "status"
  end

  create_table "employee_salary_structures", :force => true do |t|
    t.integer "employee_id"
    t.integer "payroll_category_id"
    t.string  "amount"
  end

  create_table "employee_uploads", :force => true do |t|
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", :force => true do |t|
    t.integer  "employee_category_id"
    t.string   "employee_number"
    t.date     "joining_date"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.boolean  "gender"
    t.string   "job_title"
    t.integer  "employee_position_id"
    t.integer  "employee_department_id"
    t.integer  "reporting_manager_id"
    t.integer  "employee_grade_id"
    t.string   "qualification"
    t.text     "experience_detail"
    t.integer  "experience_year"
    t.integer  "experience_month"
    t.boolean  "status"
    t.string   "status_description"
    t.date     "date_of_birth"
    t.string   "marital_status"
    t.integer  "children_count"
    t.string   "father_name"
    t.string   "mother_name"
    t.string   "husband_name"
    t.string   "blood_group"
    t.integer  "nationality_id"
    t.string   "home_address_line1"
    t.string   "home_address_line2"
    t.string   "home_city"
    t.string   "home_state"
    t.integer  "home_country_id"
    t.string   "home_pin_code"
    t.string   "office_address_line1"
    t.string   "office_address_line2"
    t.string   "office_city"
    t.string   "office_state"
    t.integer  "office_country_id"
    t.string   "office_pin_code"
    t.string   "office_phone1"
    t.string   "office_phone2"
    t.string   "mobile_phone"
    t.string   "home_phone"
    t.string   "email"
    t.string   "fax"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.binary   "photo_data",             :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_file_size"
    t.integer  "user_id"
  end

  add_index "employees", ["employee_number"], :name => "index_employees_on_employee_number"

  create_table "employees_subjects", :force => true do |t|
    t.integer "employee_id"
    t.integer "subject_id"
  end

  add_index "employees_subjects", ["subject_id"], :name => "index_employees_subjects_on_subject_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_common",   :default => false
    t.boolean  "is_holiday",  :default => false
    t.boolean  "is_exam",     :default => false
    t.boolean  "is_due",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["is_common", "is_holiday", "is_exam"], :name => "index_events_on_is_common_and_is_holiday_and_is_exam"

  create_table "exam_groups", :force => true do |t|
    t.string  "name"
    t.integer "batch_id"
    t.string  "exam_type"
    t.boolean "is_published",     :default => false
    t.boolean "result_published", :default => false
    t.date    "exam_date"
  end

  create_table "exam_scores", :force => true do |t|
    t.integer  "student_id"
    t.integer  "exam_id"
    t.decimal  "marks",            :precision => 7, :scale => 2
    t.integer  "grading_level_id"
    t.string   "remarks"
    t.boolean  "is_failed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exam_scores", ["student_id", "exam_id"], :name => "index_exam_scores_on_student_id_and_exam_id"

  create_table "exams", :force => true do |t|
    t.integer  "exam_group_id"
    t.integer  "subject_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "maximum_marks"
    t.integer  "minimum_marks"
    t.integer  "grading_level_id"
    t.integer  "weightage",        :default => 0
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exams", ["exam_group_id", "subject_id"], :name => "index_exams_on_exam_group_id_and_subject_id"

  create_table "fee_collection_discounts", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "receiver_id"
    t.integer  "finance_fee_collection_id"
    t.decimal  "discount",                  :precision => 15, :scale => 2
    t.boolean  "is_amount",                                                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fee_collection_particulars", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",                    :precision => 12, :scale => 2
    t.integer  "finance_fee_collection_id"
    t.integer  "student_category_id"
    t.string   "admission_no"
    t.integer  "student_id"
    t.boolean  "is_deleted",                                               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fee_discounts", :force => true do |t|
    t.string  "type"
    t.string  "name"
    t.integer "receiver_id"
    t.integer "finance_fee_category_id"
    t.decimal "discount",                :precision => 15, :scale => 2
    t.boolean "is_amount",                                              :default => false
  end

  create_table "finance_donations", :force => true do |t|
    t.string   "donor"
    t.string   "description"
    t.decimal  "amount",           :precision => 12, :scale => 2
    t.date     "transaction_date"
    t.integer  "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "finance_fee_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "batch_id"
    t.boolean  "is_deleted",  :default => false, :null => false
    t.boolean  "is_master",   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "finance_fee_collections", :force => true do |t|
    t.string  "name"
    t.date    "start_date"
    t.date    "end_date"
    t.date    "due_date"
    t.integer "fee_category_id"
    t.integer "batch_id"
    t.boolean "is_deleted",      :default => false, :null => false
  end

  add_index "finance_fee_collections", ["fee_category_id"], :name => "index_finance_fee_collections_on_fee_category_id"

  create_table "finance_fee_particulars", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",                  :precision => 8, :scale => 2
    t.integer  "finance_fee_category_id"
    t.integer  "student_category_id"
    t.string   "admission_no"
    t.integer  "student_id"
    t.boolean  "is_deleted",                                            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "finance_fee_structure_elements", :force => true do |t|
    t.decimal "amount",              :precision => 8, :scale => 2
    t.string  "label"
    t.integer "batch_id"
    t.integer "student_category_id"
    t.integer "student_id"
    t.integer "parent_id"
    t.integer "fee_collection_id"
    t.boolean "deleted",                                           :default => false
  end

  create_table "finance_fees", :force => true do |t|
    t.integer "fee_collection_id"
    t.string  "transaction_id"
    t.integer "student_id"
  end

  add_index "finance_fees", ["fee_collection_id", "student_id"], :name => "index_finance_fees_on_fee_collection_id_and_student_id"

  create_table "finance_transaction_categories", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.boolean "is_income"
    t.boolean "deleted",     :default => false, :null => false
  end

  create_table "finance_transaction_triggers", :force => true do |t|
    t.integer "finance_category_id"
    t.decimal "percentage",          :precision => 8, :scale => 2
    t.string  "title"
    t.string  "description"
  end

  create_table "finance_transactions", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.decimal  "amount",                :precision => 15, :scale => 2
    t.date     "transaction_date"
    t.boolean  "fine_included",                                        :default => false
    t.decimal  "fine_amount",           :precision => 10, :scale => 2, :default => 0.0
    t.integer  "master_transaction_id",                                :default => 0
    t.integer  "category_id"
    t.integer  "student_id"
    t.integer  "finance_fees_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grading_levels", :force => true do |t|
    t.string   "name"
    t.integer  "batch_id"
    t.integer  "min_score"
    t.integer  "order"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grading_levels", ["batch_id", "is_deleted"], :name => "index_grading_levels_on_batch_id_and_is_deleted"

  create_table "group_files", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.string   "file_description"
    t.integer  "group_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.datetime "doc_updated_at"
  end

  create_table "group_members", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "is_admin",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_post_comments", :force => true do |t|
    t.integer  "group_post_id"
    t.integer  "user_id"
    t.text     "comment_body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_posts", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.string   "post_title"
    t.text     "post_body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grouped_exams", :force => true do |t|
    t.integer "exam_group_id"
    t.integer "batch_id"
  end

  add_index "grouped_exams", ["batch_id"], :name => "index_grouped_exams_on_batch_id"

  create_table "groups", :force => true do |t|
    t.string   "group_name"
    t.text     "group_description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "guardians", :force => true do |t|
    t.integer  "ward_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "relation"
    t.string   "email"
    t.string   "office_phone1"
    t.string   "office_phone2"
    t.string   "mobile_phone"
    t.string   "office_address_line1"
    t.string   "office_address_line2"
    t.string   "city"
    t.string   "state"
    t.integer  "country_id"
    t.date     "dob"
    t.string   "occupation"
    t.string   "income"
    t.string   "education"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "passport_no"
    t.integer  "iqama_no"
    t.integer  "fax_no"
  end

  create_table "individual_payslip_categories", :force => true do |t|
    t.integer "employee_id"
    t.date    "salary_date"
    t.string  "name"
    t.string  "amount"
    t.boolean "is_deduction"
    t.boolean "include_every_month"
  end

  create_table "languages", :force => true do |t|
    t.string "name"
    t.string "code"
  end

  create_table "liabilities", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "amount"
    t.boolean  "is_solved",   :default => false
    t.boolean  "is_deleted",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monthly_payslips", :force => true do |t|
    t.date    "salary_date"
    t.integer "employee_id"
    t.integer "payroll_category_id"
    t.string  "amount"
    t.boolean "is_approved",         :default => false, :null => false
    t.boolean "is_rejected",         :default => false, :null => false
    t.integer "approver_id"
    t.integer "rejector_id"
    t.string  "reason"
  end

  create_table "news", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_comments", :force => true do |t|
    t.text     "content"
    t.integer  "news_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisation_uploads", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.boolean  "status"
    t.boolean  "is_active",          :default => true
    t.boolean  "is_deleted",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
  end

  create_table "payroll_categories", :force => true do |t|
    t.string  "name"
    t.float   "percentage"
    t.integer "payroll_category_id"
    t.boolean "is_deduction"
    t.boolean "status"
  end

  create_table "period_entries", :force => true do |t|
    t.date    "month_date"
    t.integer "batch_id"
    t.integer "subject_id"
    t.integer "class_timing_id"
    t.integer "employee_id"
  end

  add_index "period_entries", ["month_date", "batch_id"], :name => "index_period_entries_on_month_date_and_batch_id"

  create_table "privileges", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privileges_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "privilege_id"
  end

  add_index "privileges_users", ["user_id"], :name => "index_privileges_users_on_user_id"

  create_table "registration_forms", :force => true do |t|
    t.string   "register_number"
    t.date     "registration_date"
    t.string   "academic_year1"
    t.string   "academic_year2"
    t.string   "batch_id"
    t.string   "bus_facility"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "gender"
    t.date     "date_of_birth"
    t.string   "age"
    t.string   "religion"
    t.integer  "nationality_id"
    t.string   "name_of_a_previous_school"
    t.string   "father_first_name"
    t.string   "father_last_name"
    t.string   "qualification"
    t.string   "mob_no"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "home_address_line1"
    t.string   "home_address_line2"
    t.string   "pin_code"
    t.string   "state"
    t.string   "po_box"
    t.string   "signature"
    t.string   "courses"
    t.date     "date_of_exam"
    t.string   "timings"
    t.boolean  "is_active",                 :default => true
    t.boolean  "is_deleted",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  create_table "reminders", :force => true do |t|
    t.integer  "sender"
    t.integer  "recipient"
    t.string   "subject"
    t.text     "body",                    :limit => 2147483647
    t.boolean  "is_read",                                       :default => false
    t.boolean  "is_deleted_by_sender",                          :default => false
    t.boolean  "is_deleted_by_recipient",                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reminders", ["recipient"], :name => "index_reminders_on_recipient"

  create_table "sms_settings", :force => true do |t|
    t.string  "settings_key"
    t.boolean "is_enabled",   :default => false
  end

  create_table "student_additional_details", :force => true do |t|
    t.integer "student_id"
    t.integer "additional_field_id"
    t.string  "additional_info"
  end

  create_table "student_additional_fields", :force => true do |t|
    t.string  "name"
    t.boolean "status"
  end

  create_table "student_categories", :force => true do |t|
    t.string  "name"
    t.boolean "is_deleted", :default => false, :null => false
  end

  create_table "student_previous_datas", :force => true do |t|
    t.integer "student_id"
    t.string  "institution"
    t.string  "year"
    t.string  "course"
    t.string  "total_mark"
    t.integer "country_id"
  end

  create_table "student_previous_subject_marks", :force => true do |t|
    t.integer "student_id"
    t.string  "subject"
    t.string  "mark"
  end

  create_table "students", :force => true do |t|
    t.string   "admission_no"
    t.string   "class_roll_no"
    t.date     "admission_date"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.integer  "batch_id"
    t.date     "date_of_birth"
    t.string   "gender"
    t.string   "blood_group"
    t.string   "birth_place"
    t.integer  "nationality_id"
    t.string   "language"
    t.string   "religion"
    t.integer  "student_category_id"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "city"
    t.string   "state"
    t.string   "pin_code"
    t.integer  "country_id"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "email"
    t.integer  "immediate_contact_id"
    t.boolean  "is_sms_enabled",                           :default => true
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.binary   "photo_data",           :limit => 16777215
    t.string   "status_description"
    t.boolean  "has_paid_fees",                            :default => false
    t.boolean  "is_active",                                :default => true
    t.boolean  "is_deleted",                               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_file_size"
    t.integer  "sibling_id"
    t.integer  "street_no"
    t.integer  "flat_no"
    t.string   "locality"
    t.integer  "po_box_no"
    t.string   "city1"
    t.string   "state1"
    t.integer  "country1_id"
    t.string   "pin"
    t.integer  "telephone"
    t.string   "mobile_no"
    t.string   "second_language"
    t.string   "thrid_language"
    t.integer  "user_id"
    t.integer  "photo_file_size"
  end

  add_index "students", ["admission_no"], :name => "index_students_on_admission_no"
  add_index "students", ["first_name", "middle_name", "last_name"], :name => "index_students_on_first_name_and_middle_name_and_last_name"

  create_table "students_subjects", :force => true do |t|
    t.integer "student_id"
    t.integer "subject_id"
    t.integer "batch_id"
  end

  add_index "students_subjects", ["student_id", "subject_id"], :name => "index_students_subjects_on_student_id_and_subject_id"

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "batch_id"
    t.boolean  "no_exams",           :default => false
    t.integer  "max_weekly_classes"
    t.integer  "elective_group_id"
    t.boolean  "is_deleted",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subjects", ["batch_id", "elective_group_id", "is_deleted"], :name => "index_subjects_on_batch_id_and_elective_group_id_and_is_deleted"

  create_table "timetable_entries", :force => true do |t|
    t.integer "batch_id"
    t.integer "weekday_id"
    t.integer "class_timing_id"
    t.integer "subject_id"
    t.integer "employee_id"
  end

  add_index "timetable_entries", ["weekday_id", "batch_id", "class_timing_id"], :name => "by_timetable"

  create_table "uploads", :force => true do |t|
    t.integer  "organisation_upload_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "admin"
    t.boolean  "student"
    t.boolean  "employee"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "reset_password_code"
    t.datetime "reset_password_code_until"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "index_users_on_username"

  create_table "weekdays", :force => true do |t|
    t.integer "batch_id"
    t.string  "weekday"
  end

  add_index "weekdays", ["batch_id"], :name => "index_weekdays_on_batch_id"

  create_table "xmls", :force => true do |t|
    t.string   "finance_name"
    t.string   "ledger_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
