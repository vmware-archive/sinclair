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
    def initialize(key, status)
      @key = key
      @status = status
    end

    def message
      "Error making OpenAir request for #{@key}. Got status #{@status}."
    end
  end
end
