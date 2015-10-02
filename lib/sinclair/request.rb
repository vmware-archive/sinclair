require 'erb'
require 'ostruct'

module Sinclair
  class Request
    def initialize(body)
      @body = body
      @header = File.read(File.expand_path('../templates/request_header.xml.erb', __FILE__))
    end

    def render(locals)
      templates = [@body, @header]
      templates.inject(nil) do |prev, temp|
        _render(temp, locals) { prev }
      end
    end

    private

    def _render(temp, locals)
      ERB.new(temp).result(OpenStruct.new(locals).instance_eval { binding }).strip
    end
  end
end
