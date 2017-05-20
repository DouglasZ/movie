class AddCastOfTheMovie < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :cast, :string
  end
end
