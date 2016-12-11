class RemoveEndDateFromPresidents < ActiveRecord::Migration
  def change
    remove_column :presidents, :end_date, :string
  end
end
