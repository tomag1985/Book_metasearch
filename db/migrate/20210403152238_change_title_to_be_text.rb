class ChangeTitleToBeText < ActiveRecord::Migration[6.0]
  def change
    change_column :books, :title, :text
  end
end
