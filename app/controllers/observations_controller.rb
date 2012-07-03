class ObservationsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def show
    @observation=Observation.find params[:id]
    @descriptives=@observation.descriptive_indicators
  end

end
