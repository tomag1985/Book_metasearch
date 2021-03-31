class AddImgSourceToBooks < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :img_src, :string
  end
end
