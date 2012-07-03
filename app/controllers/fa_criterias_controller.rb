class FaCriteriasController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @fa_group=FaGroup.find(params[:fa_group_id])
    @fa_criterias=@fa_group.fa_criterias
  end

  def show
    @fa_criteria=FaCriteria.find(params[:id])
    @descriptives=@fa_criteria.descriptive_indicators
  end

end
