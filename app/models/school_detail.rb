class SchoolDetail < ActiveRecord::Base
  has_attached_file :logo,
  :styles => { :original=> "150x110#"},
  :url => "/system/:class/:attachment/:id_partition/:style/:basename.:extension",
  :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:basename.:extension",
  :default_url  => 'application/app_fedena_logo.png',
  :default_path  => ':rails_root/public/images/application/app_fedena_logo.png'

  VALID_IMAGE_TYPES = ['image/gif', 'image/png','image/jpeg', 'image/jpg']

  validates_attachment_content_type :logo, :content_type =>VALID_IMAGE_TYPES,
  :message=>'Image can only be GIF, PNG, JPG',:if=> Proc.new { |p| !p.logo_file_name.blank? }
  validates_attachment_size :logo, :less_than => 512000,
  :message=>'must be less than 500 KB.',:if=> Proc.new { |p| p.logo_file_name_changed? }

end
