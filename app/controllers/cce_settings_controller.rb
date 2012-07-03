class CceSettingsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
  end

  def basic
  end

  def scholastic
  end

  def co_scholastic
  end

end
