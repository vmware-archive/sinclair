require 'nori'
require 'faraday'
require 'nokogiri'

module Sinclair
  class OpenAirApiClient

    def initialize(username:, password:, company:, client:, key:, url: 'https://www.openair.com', limit: '1000', timeout: 180, open_timeout: 120)
      @username = username
      @password = password
      @company = company
      @client = client
      @key = key
      @url = url
      @limit = limit
      @timeout = timeout
      @open_timeout = open_timeout
    end

    def send_request(template: template, key: key, locals: {})
      response = []
      while true
        page = process_page(template, key, {offset: response.length}.merge(locals))
        page.flatten!
        break unless page
        response += page
        break if page.length < @limit.to_i
      end
      response
    end

    private

    def process_page(template, key, locals = {})
      response = make_request(locals, template)
      check_auth_status(response)

      read = response['response']['Read']
      read = [read] unless read.is_a?(Array)

      check_read_status(read)

      read.map { |r| r[key] }
    end

    def make_request(locals, template)
      response = get_response(template, locals)
      Nori.new(advanced_typecasting: false).parse(response.body)
    end

    def invalid_read_status(status)
      status != 0 && status != 601
    end

    def check_auth_status(response)
      raise Sinclair::OpenAirResponseUnrecognized if response['response']['Auth'].nil?

      auth_status = response['response']['Auth']['@status'].to_i
      raise Sinclair::OpenAirUserLocked if auth_status == 416
      raise Sinclair::OpenAirAuthenticationFailure if auth_status != 0
    end

    def check_read_status(read)
      statuses = read.map { |r| r['@status'].to_i }
      if statuses.any? { |s| invalid_read_status(s) }
        raise Sinclair::OpenAirResponseError.new(statuses.find { |s| invalid_read_status(s) })
      end
    end

    def get_response(template, locals = {})
      options = {request: {timeout: @timeout, open_timeout: @open_timeout}}
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

    def wrap_response(response)
      response.is_a?(Array) ? response : [response]
    end
  end
end
