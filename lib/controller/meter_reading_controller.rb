require 'sinatra/base'
require_relative '../service/electricty_reading_service'
require_relative '../../lib/service/account_service.rb'

class MeterReadingController < Sinatra::Base
  def initialize(app = nil, electricity_reading_service, account_service)
    super(app)
    @electricity_reading_service = electricity_reading_service
    @account_service = account_service
  end

  before do
    if request.post? && request.body.length > 0
      request.body.rewind
      @request_payload = JSON.parse request.body.read
    end
  end

  get '/readings/read/{meter_id}' do
    content_type :json
    @electricity_reading_service.getReadings(@params['meter_id']).to_json
  end

  get '/readings/read/:meter_id/cost/:days' do
    content_type :json
    meter_id = @params[:meter_id]
    price_plan = @account_service.price_plan_for_meter(meter_id)
    if price_plan.nil?
      status 404
    else
      # TODO: status 200
    end
  end

  post '/readings/store' do
    readings = @request_payload['electricityReadings']
    if readings && readings.length > 0
      meter_id = @request_payload['smartMeterId']
      @electricity_reading_service.storeReadings(meter_id, readings)
      status 200
    else
      status 500
    end
  end
end
