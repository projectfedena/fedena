class AssessmentToolsController < ApplicationController
  def index
    @descriptive=DescriptiveIndicator.find(params[:descriptive_indicator_id])
    @assessment_tools=@descriptive.assessment_tools
    @describable=@descriptive.describable
    if @descriptive.describable_type == "Observation"
      @observation_group=@describable.observation_group
    else
      @fa_group=@describable.fa_group
    end
  end

  def new
    @descriptive=DescriptiveIndicator.find(params[:id])
    @assessment_tool=AssessmentTool.new
  end

  def create
    @assessment_tool=AssessmentTool.new(params[:assessment_tool])
    if @assessment_tool.save
      @assessment_tools=@assessment_tool.descriptive_indicator.assessment_tools
      flash[:notice]=t("descriptive_indicator_created")
    else
      @error=true
    end
  end

  def edit
    @assessment_tool=AssessmentTool.find(params[:id])
  end

  def update
    @assessment_tool=AssessmentTool.find(params[:id])
    @assessment_tool.attributes=(params[:assessment_tool])
    if @assessment_tool.save
      @assessment_tools=@assessment_tool.descriptive_indicator.assessment_tools
      flash[:notice]=t("descriptive_indicator_updated")
    else
      @error=true
    end
  end

end
