class AddOriginalTitleToMovies < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :original_title, :string
  end
end
