class ClassDesignationsController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def index
    #@class_designations = ClassDesignation.all
    #@class_designation = ClassDesignation.new
  end

  def load_class_designations
    unless params[:course_id]==""
      @course = Course.find(params[:course_id])
      @class_designations = ClassDesignation.find(:all,:conditions=>{:course_id=>@course.id})
      @class_designation = ClassDesignation.new
      render(:update) do|page|
        page.replace_html "course_class_designations", :partial=>"course_class_designations"
        page.replace_html 'flash', :text=>""
      end
    else
      render(:update) do|page|
        page.replace_html "course_class_designations", :text=>""
        page.replace_html 'flash', :text=>""
      end
    end
  end

  def create_class_designation
    @course = Course.find(params[:course_id])
    @class_designation = ClassDesignation.new(params[:class_designation])
    @class_designation.course_id = @course.id
    if @class_designation.save
      @class_designation = ClassDesignation.new
      @class_designations = @course.class_designations.all
      render(:update) do|page|
        page.replace_html "category-list", :partial=>"class_designations"
        page.replace_html 'flash', :text=>"<p class='flash-msg'>#{t('class_designations.flash1')}</p>"
        page.replace_html 'errors', :partial=>"form_errors"
        page.replace_html 'class_form', :partial=>"class_form"
      end
    else
      render(:update) do|page|
        page.replace_html 'errors', :partial=>'form_errors'
        page.replace_html 'flash', :text=>""
      end
    end
  end

  def edit_class_designation
    @class_designation = ClassDesignation.find(params[:id])
    @course = @class_designation.course
    render(:update) do|page|
      page.replace_html "class_form", :partial=>"class_edit_form"
      page.replace_html 'errors', :partial=>'form_errors'
      page.replace_html 'flash', :text=>""
    end
  end

  def update_class_designation
    @class_designation = ClassDesignation.find(params[:id])
    @course = @class_designation.course
    if @class_designation.update_attributes(params[:class_designation])
      @class_designation = ClassDesignation.new
      @class_designations = @course.class_designations.all
      render(:update) do|page|
        page.replace_html "category-list", :partial=>"class_designations"
        page.replace_html 'flash', :text=>"<p class='flash-msg'> #{t('class_designations.flash2')}</p>"
        page.replace_html 'errors', :partial=>"form_errors"
        page.replace_html 'class_form', :partial=>"class_form"
      end
    else
      render(:update) do|page|
        page.replace_html 'errors', :partial=>'form_errors'
        page.replace_html 'flash', :text=>""
      end
    end
  end

  def delete_class_designation
    @class_designation = ClassDesignation.find(params[:id])
    @course = @class_designation.course
    @class_designation.destroy
    @class_designation = ClassDesignation.new
    @class_designations = @course.class_designations.all
    render(:update) do|page|
      page.replace_html "category-list", :partial=>"class_designations"
      page.replace_html 'flash', :text=>"<p class='flash-msg'>#{t('class_designations.flash3')}</p>"
      page.replace_html 'errors', :partial=>"form_errors"
      page.replace_html 'class_form', :partial=>"class_form"
    end
    
  end

end
