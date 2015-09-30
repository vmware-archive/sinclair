module Sinclair
  class OpenAirResponseUnrecognized < StandardError
  end

  class OpenAirResponseTimeout < StandardError
  end

  class OpenAirAuthenticationFailure < StandardError
  end

  class OpenAirUserLocked < StandardError
  end

  class OpenAirResponseError < StandardError
    def initialize(status)
      @status = status
    end

    def message
      "Error making OpenAir request. Got status #{@status}."
    end
  end
end
