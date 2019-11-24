class CarModel < ApplicationRecord
  has_many :car_versions

  def self.to_csv options={}
    CSV.generate(options) do |csv|
      csv << ["Type", "Title", "Price"]
      all.each do |model|
        csv << [ model.class.name, model.title, '']
        model.car_versions.each do |version|
          csv << [version.class.name, version.title, version.price]
        end
      end
    end
  end
end
