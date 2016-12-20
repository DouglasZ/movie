class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string :name
      t.date :release_date
      t.integer :status
      t.string :director
      t.string :gender
      t.text :synopsis
      t.text :image_link

      t.timestamps
    end
  end
end
