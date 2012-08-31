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
