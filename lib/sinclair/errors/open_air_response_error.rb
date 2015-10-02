module Sinclair
  class OpenAirResponseError < StandardError
    attr_reader :status

    def initialize(status)
      @status = status
    end

    def message
      "Error making OpenAir request. Got status #{@status}."
    end
  end
end
