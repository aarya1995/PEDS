class AddDescriptionToPresidents < ActiveRecord::Migration
  def change
    add_column :presidents, :description, :text
  end
end
