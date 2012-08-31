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
