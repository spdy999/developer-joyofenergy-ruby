require_relative '../../lib/service/price_plan_service.rb'
require_relative '../../lib/service/electricty_reading_service.rb'
require_relative '../../lib/domain/price_plan'
require 'rspec'

describe PricePlanService do
  PRICE_PLAN_1_ID = 'test-supplier'
  PRICE_PLAN_2_ID = 'best-supplier'
  PRICE_PLAN_3_ID = 'second-best-supplier'

  let(:app) { described_class.new price_plan_service, account_service }
  let(:price_plan_service) { PricePlanService.new price_plans, electricity_reading_service }
  let(:electricity_reading_service) { ElectricityReadingService.new }
  let(:account_service) { AccountService.new 'meter-0' => PRICE_PLAN_1_ID }
  let(:price_plans) { [
    PricePlan.new(PRICE_PLAN_1_ID, nil, 10.0, nil),
    PricePlan.new(PRICE_PLAN_2_ID, nil, 1.0, nil),
    PricePlan.new(PRICE_PLAN_3_ID, nil, 2.0, nil)
  ] }

  it 'should return cost from meter_id, price_plan and days' do
    PRICE_PLAN_1_ID = 'test-supplier'
    price_plans = [
      PricePlan.new(PRICE_PLAN_1_ID, nil, 10.0, nil),
      PricePlan.new(PRICE_PLAN_2_ID, nil, 1.0, nil),
      PricePlan.new(PRICE_PLAN_3_ID, nil, 2.0, nil)
    ]
    electricity_reading_service = ElectricityReadingService.new
    price_plan_service = PricePlanService.new price_plans, electricity_reading_service
    # let(:price_plan_service) { PricePlanService.new price_plans, electricity_reading_service }
    # let(:electricity_reading_service) { ElectricityReadingService.new }
    # let(:account_service) { AccountService.new 'meter-0' => PRICE_PLAN_1_ID }
    # let(:price_plans) {[
    #   PricePlan.new(PRICE_PLAN_1_ID, nil, 10.0, nil),
    #   PricePlan.new(PRICE_PLAN_2_ID, nil, 1.0, nil),
    #   PricePlan.new(PRICE_PLAN_3_ID, nil, 2.0, nil)
    # ]}
    # meter_reading_service = ElectricityReadingService.new price_plan_service
    electricity_readings = [
      { 'time': '2018-01-01T00:00:00.000Z', 'reading': 1.5 },
      { 'time': (DateTime.now - 1).to_s, 'reading': 1.5 },
      { 'time': '2018-01-01T00:00:00.000Z', 'reading': 1.5 }
    ]
    puts electricity_readings
    puts '===='
    smart_meter_id = '0101010'
    electricity_reading_service.storeReadings smart_meter_id, electricity_readings
    # readings_record = {
    #   'smartMeterId' => smartMeterId,
    #   'electricityReadings' => electricityReadings
    # }
    # meter_reading_service.storeReadings(smart_meter_id, electricity_readings)
    # expect(meter_reading_service.getReadings(smart_meter_id)).to eq electricity_readings
    expect(price_plan_service.calculate_cost_by_days(electricity_readings, PRICE_PLAN_1_ID, 7)).to eq 0
  end
end