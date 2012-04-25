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

class NewsController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def add
    @news = News.new(params[:news])
    @news.author = current_user
    if request.post? and @news.save
      sms_setting = SmsSetting.new()
      if sms_setting.application_sms_active
        students = Student.find(:all,:select=>'phone2',:conditions=>'is_sms_enabled = true')
      end
      flash[:notice] = "#{t('flash1')}"
      redirect_to :controller => 'news', :action => 'view', :id => @news.id
    end
  end

  def add_comment
    @cmnt = NewsComment.new(params[:comment])
    @cmnt.author = current_user
    @cmnt.is_approved =true if @current_user.privileges.include?(Privilege.find_by_name('ManageNews')) || @current_user.admin?
    @config = Configuration.find_by_config_key('EnableNewsCommentModeration') 
    @cmnt.save
  end

  def all
    @news = News.paginate :page => params[:page]
  end

  def delete
    @news = News.find(params[:id]).destroy
    flash[:notice] = "#{t('flash2')}"
    redirect_to :controller => 'news', :action => 'index'
  end

  def delete_comment
    @comment = NewsComment.find(params[:id])
    NewsComment.destroy(params[:id])
  end

  def edit
    @news = News.find(params[:id])
    if request.post? and @news.update_attributes(params[:news])
      flash[:notice] = "#{t('flash3')}"
      redirect_to :controller => 'news', :action => 'view', :id => @news.id
    end
  end

  def index
    @current_user = current_user
    @news = []
    if request.get?
      @news = News.title_like_all params[:query].split unless params[:query].nil?
    end
  end

  def search_news_ajax
    @news = nil
    conditions = ["title LIKE ?", "%#{params[:query]}%"]
    @news = News.find(:all, :conditions => conditions) unless params[:query] == ''
    render :layout => false
  end

  def view
    @current_user = current_user
    @news = News.find(params[:id])
    @comments = @news.comments
    @is_moderator = @current_user.privileges.include?(Privilege.find_by_name('ManageNews')) || @current_user.admin?
    @config = Configuration.find_by_config_key('EnableNewsCommentModeration') 
  end

  def comment_approved
    @comment = NewsComment.find(params[:id])
    status=@comment.is_approved ? false : true
    @comment.update_attributes(:is_approved=>status)
    render :update do |page|
      page.reload
    end
  end
end
