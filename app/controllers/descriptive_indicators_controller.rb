class DescriptiveIndicatorsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def new
    if params[:observation_id]
      @observation=Observation.find(params[:observation_id])
      @descriptive=@observation.descriptive_indicators.new
    elsif params[:fa_criteria_id]
      @fa_criteria=FaCriteria.find(params[:fa_criteria_id])
      @descriptive=@fa_criteria.descriptive_indicators.new
    end
  end

  def create
    @describable=Observation.find(params[:observation_id]) if params[:observation_id]
    @describable=FaCriteria.find(params[:fa_criteria_id]) if params[:fa_criteria_id]
    @descriptive=@describable.descriptive_indicators.new(params[:descriptive_indicator])
    @descriptive.sort_order=@describable.descriptive_indicators.find(:last).try(:sort_order).to_i+1 || 1
    if @descriptive.save
      @descriptive_indicators=@descriptive.describable.descriptive_indicators.all
      @observation=@descriptive if params[:observation_id]
      @fa_criteria=@descriptive  if params[:fa_criteria_id]
      flash[:notice]="Descriptive Indicator Created Successfully."
    else
      @observation=Observation.find(params[:observation_id]) if params[:observation_id]
      @fa_criteria=FaCriteria.find(params[:fa_criteria_id]) if params[:fa_criteria_id]
      @error=true
      #      render 'new'
    end
  end

  def index
    if params[:observation_id]
      @observation=Observation.find(params[:observation_id])
      @descriptive_indicators=@observation.descriptive_indicators.all
      @observation_group=@observation.observation_group
    elsif params[:fa_criteria_id]
      @fa_criteria=FaCriteria.find(params[:fa_criteria_id])
      @descriptive_indicators=@fa_criteria.descriptive_indicators.all
      @fa_group=@fa_criteria.fa_group
    end
  end

  def edit
    @descriptive=DescriptiveIndicator.find(params[:id])
  end

  def update
    @descriptive=DescriptiveIndicator.find(params[:id])
    @descriptive.attributes=(params[:descriptive_indicator])
    if @descriptive.save
      @descriptive_indicators=@descriptive.describable.descriptive_indicators.all
      @observation=@descriptive if @descriptive.describable_type == "Observation"
      @fa_criteria=@descriptive if @descriptive.describable_type == "FaCriteria"
      flash[:notice]="Descriptive Indicator Updated Successfully."
    else
      @error=true
      #      render 'edit'
    end
  end

  def show
    
  end

  def destroy_indicator
    @descriptive_indicator=DescriptiveIndicator.find(params[:id])
    if @descriptive_indicator.destroy
      flash[:notice]="Descriptive indicator deleted."
    else
      flash[:notice]="Unable to delete the descriptive indicator"
    end
    @descriptive_indicators=@descriptive_indicator.describable.descriptive_indicators.all(:order=>"sort_order ASC")
    render(:update) do |page|
      page.replace_html 'flash-box', :text=>"<p class='flash-msg'>#{flash[:notice]}</p>" unless flash[:notice].nil?
      page.replace_html 'descriptive_indicators', :partial => 'descriptive_indicators', :object => @descriptive_indicators
    end
  end

  def reorder
    if request.post?
      descriptive_indicator=DescriptiveIndicator.find(params[:id])
      describable=descriptive_indicator.describable
      swap=describable.descriptive_indicators.all
      initial=params[:count].to_i
      src=swap[initial]
      if params[:direction]=='up'
        dest=swap[initial-1]
      elsif params[:direction]=='down'
        dest=swap[initial+1]
      end
      dest_id=dest.sort_order.to_i
      dest.update_attribute(:sort_order,src.sort_order.to_i)
      src.update_attribute(:sort_order,dest_id)
      @descriptive_indicators=describable.descriptive_indicators.all
      render(:update) do |page|
        page.replace_html 'descriptive_indicators', :partial => 'descriptive_indicators', :object => @descriptive_indicators
      end
    end
  end

end
