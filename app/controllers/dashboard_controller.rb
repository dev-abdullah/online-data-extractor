class DashboardController < ApplicationController
  before_action :set_url, only: [:fetch_cars_details]

  def index
  end

  def fetch_cars_details
    if @url.present?
      @parsed_page = get_parsed_page(@url)
      cars_with_2020_model = get_specific_model_cars('toyota2020')
      cars_with_2019_model = get_specific_model_cars('toyota2019')
      cars_with_2018_model = get_specific_model_cars('toyota2018')
      @car_models = CarModel.all
      respond_to do |format|
        format.html
        format.csv {
          send_data @car_models.to_csv, filename: "Cars-#{Date.today}.csv"
        }
      end
    else
      redirect_to root_path
    end
  end

  private

  def set_url
    @url = params[:fetch_cars][:search_path]
  end

  def get_specific_model_cars(model)
    cars = @parsed_page.css("div##{model}").css('div.list-models')
    cars.each do |car|
      title = car.css('h3').text.gsub("\n", ' ').squeeze(' ')
      url   = "https://uae.yallamotor.com/#{car.css('a')[0].attributes['href'].value}"
      new_parsed_page = get_parsed_page(url)
      car_model = CarModel.where(title: title).first_or_create!
      get_specific_car_versions(car_model, new_parsed_page)
    end
  end

  def get_parsed_page url
    unparsed_page  = HTTParty.get(url)
    Nokogiri::HTML(unparsed_page)
  end

  def get_specific_car_versions car_model, new_parsed_page
    versions = new_parsed_page.css('div.match-version')
    versions.each do |version|
      title = version.css('h3.pro-name').text.gsub("\n", ' ').squeeze(' ')
      price = version.css('span.pro-pice').text
      car_version = car_model.car_versions.where(title: title, price: price).first_or_create!
    end
  end
end
