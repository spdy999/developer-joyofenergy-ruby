ENV['RACK_ENV'] = 'test'

require_relative '../../lib/controller/meter_reading_controller.rb'
require_relative '../../lib/service/account_service.rb'
require 'json'
require 'rspec'
require 'rack/test'

describe MeterReadingController do
  include Rack::Test::Methods

  PRICE_PLAN_1_ID = 'test-supplier'

  let(:app) { described_class.new(electricity_reading_service, account_service) }
  let(:electricity_reading_service) { ElectricityReadingService.new }
  let(:account_service) { AccountService.new 'meter-0' => PRICE_PLAN_1_ID }

  describe '/readings/store' do

    it 'should store a meter reading against a new meter' do
      readings_record = {
        'smartMeterId' => '0101010',
        'electricityReadings' => [
          { 'time': '2018-01-01T00:00:00.000Z', 'reading': 1.5 },
          { 'time': '2018-01-01T00:00:00.000Z', 'reading': 1.5 }
        ]
      }
      post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response).to be_ok

      get '/readings/read/0101010'
      expect(JSON.parse(last_response.body).length).to eq 2
    end

    it 'should store more meter readings against an existing meter' do
      readings_record = {
        'smartMeterId' => '0101010',
        'electricityReadings' => [
          { 'time': '2018-01-01T00:00:00.000Z', 'reading': 1.5 },
          { 'time': '2018-01-01T00:00:00.000Z', 'reading': 1.5 }
        ]
      }
      post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response).to be_ok

      more_readings = {
        'smartMeterId' => '0101010',
        'electricityReadings' => [
          { 'time': '2018-01-01T00:00:00.000Z', 'reading': 1.5 }
        ]
      }
      post '/readings/store', more_readings.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response).to be_ok

      get '/readings/read/0101010'
      expect(JSON.parse(last_response.body).length).to eq 3
    end

    it 'should return error response when no meter id is supplied' do
      post '/readings/store', {}.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 500
    end

    it 'should return error response when given empty readings' do
      post '/readings/store', { 'smartMeterId' => '0101010', 'electricityReadings' => [] }.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 500
    end

    it 'should return error response when readings not provided' do
      post '/readings/store', { 'smartMeterId' => '0101010' }.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 500
    end

  end

  describe '/readings/read/:smart-meter-id/cost/:day' do
    it 'should return 404 error response when price plan not attach to it' do
      get '/readings/read/0101010/cost/7'
      expect(last_response.status).to eq 404
    end
  end
end
