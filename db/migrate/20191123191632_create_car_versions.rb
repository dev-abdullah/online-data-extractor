class CreateCarVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :car_versions do |t|
      t.string :title
      t.string :price
      t.references :car_model, foreign_key: true

      t.timestamps
    end
  end
end
