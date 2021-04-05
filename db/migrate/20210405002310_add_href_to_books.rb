class AddHrefToBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :href, :string
  end
end
