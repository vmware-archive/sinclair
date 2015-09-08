require 'nori'
require 'faraday'
require 'nokogiri'

module Sinclair
  class OpenAirApiClient

    def initialize(username:, password:, company:, client:, key:, url: 'https://www.openair.com', limit: '1000', timeout: 180)
      @username = username
      @password = password
      @company = company
      @client = client
      @key = key
      @url = url
      @limit = limit
      @timeout = timeout
    end

    def send_request(template: template, key: key)
      response = []
      while true
        page = process_page(template, key, {offset: response.length})
        break unless page
        response += page
      end
      response
    end

    private

    def process_page(template, key, locals = {})
      response = get_response(File.read(template), locals)

      parsed_response = Nori.new(advanced_typecasting: false).parse(response.body)
      raise Sinclair::OpenAirResponseUnrecognized if parsed_response['response']['Auth'].nil?

      authentication_status = parsed_response['response']['Auth']['@status'].to_i
      raise Sinclair::OpenAirUserLocked if authentication_status == 416
      raise Sinclair::OpenAirAuthenticationFailure if authentication_status != 0

      parsed_response['response']['Read'][key]
    end

    def get_response(template, locals = {})
      options = {request: {timeout: @timeout, open_timeout: 10}}
      begin
        locals = locals.merge(username: @username, password: @password, company: @company, client: @client, key: @key, limit: @limit)
        Faraday.new(@url, options).post('/api.pl') do |request|
          request.body = Sinclair::Request.new(template).render(locals)
          request.headers.merge!({ 'Accept-Encoding' => 'identity' })
        end
      rescue Faraday::TimeoutError
        raise Sinclair::OpenAirResponseTimeout
      end
    end
  end
end
