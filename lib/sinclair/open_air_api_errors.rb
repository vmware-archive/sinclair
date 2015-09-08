module Sinclair
  class OpenAirResponseUnrecognized < StandardError;
  end

  class OpenAirResponseTimeout < StandardError;
  end

  class OpenAirAuthenticationFailure < StandardError;
  end

  class OpenAirUserLocked < StandardError;
  end
end
