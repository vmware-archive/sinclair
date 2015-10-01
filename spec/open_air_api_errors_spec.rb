require 'spec_helper'

describe 'OpenAir Exceptions' do
  describe Sinclair::OpenAirResponseError do
    it 'includes a status code' do
      e = Sinclair::OpenAirResponseError.new(1003)
      expect(e.status).to eq(1003)
    end
  end
end
