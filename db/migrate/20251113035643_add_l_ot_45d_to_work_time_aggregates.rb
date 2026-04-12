class AddLOt45dToWorkTimeAggregates < ActiveRecord::Migration[7.1]
  def change
    add_column :work_time_aggregates ,:l_ot_45d, :integer, :default=>0, :comment=>"法定(45)日々"
  end
end
