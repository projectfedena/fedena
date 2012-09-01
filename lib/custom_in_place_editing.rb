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

module CustomInPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def in_place_edit_with_validation_for(object, attribute)
      define_method("set_#{object}_#{attribute}") do
        klass = object.to_s.camelize.constantize
        @item = klass.find(params[:id])
        @item.send("#{attribute}=", params[:value])
        if @item.save
          render :text => CGI::escapeHTML(@item.send(attribute).to_s)
        else
          render :update do |page|
            page.alert(@item.errors.full_messages.join("\n"))
            klass.query_cache.clear_query_cache if klass.method_defined?:query_cache
            @item.reload
            page.replace_html("#{object}_#{attribute}_#{params[:id]}_edit",
              @item.send(attribute))
          end
        end
      end
    end
  end
end
