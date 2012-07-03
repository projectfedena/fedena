class AddOrderToFaCriteriaAndObservations < ActiveRecord::Migration
  def self.up
    add_column      :fa_criterias,    :sort_order,   :integer
    add_column      :observations,    :sort_order,   :integer
    add_column      :descriptive_indicators,    :sort_order,   :integer
  end

  def self.down
    remove_column    :descriptive_indicators,    :sort_order
    remove_column    :observations,    :sort_order
    remove_column    :fa_criterias,    :sort_order
  end
end
