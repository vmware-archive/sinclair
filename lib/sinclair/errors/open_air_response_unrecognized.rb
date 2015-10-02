module Sinclair
  class OpenAirResponseUnrecognized < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def message
      "Unknown OpenAir response: #{response}"
    end
  end
end
