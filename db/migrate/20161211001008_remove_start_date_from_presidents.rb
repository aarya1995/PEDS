class RemoveStartDateFromPresidents < ActiveRecord::Migration
  def change
    remove_column :presidents, :start_date, :string
  end
end
