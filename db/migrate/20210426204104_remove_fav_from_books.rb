class RemoveFavFromBooks < ActiveRecord::Migration[6.0]
  def change
    remove_column :books, :fav, :boolean
  end
end
