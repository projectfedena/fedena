class AddGradingSystemsToConfigurations < ActiveRecord::Migration
  def self.up
	Configuration.create(:config_key => "GPA", :config_value => "0")
	Configuration.create(:config_key => "CWA", :config_value => "0")
  end

  def self.down
	Configuration.find_by_config_key("GPA").delete
	Configuration.find_by_config_key("CWA").delete
  end
end
