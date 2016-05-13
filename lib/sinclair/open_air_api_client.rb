require 'nori'
require 'faraday'
require 'nokogiri'

module Sinclair
  class OpenAirApiClient
    attr_accessor :logger, :last_request, :last_response

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

    def send_request(template: , model: , method: 'Read', locals: {})
      response = {}
      response[model] = []

      while true
        page = process_page(template: template, method: method, model: model, locals: {offset: response[model].length}.merge(locals))
        break unless page[model]
        returned_models = page.keys
        returned_models.each do |m|
          response[m] ? response[m] += page[m] : response[m] = page[m]
        end
        break if page[model].length < @limit.to_i
      end
      response
    end

    private

    def process_page(template:, method:, model:, locals:  {})
      response = make_request(locals, template)

      log_request unless logger.nil?

      check_auth_status(response)

      read = response['response'][method]
      read = [read] unless read.is_a?(Array)

      check_response_status(read, model)
      map_response_by_model(read)
    end

    def make_request(locals, template)
      response = get_response(template, locals)
      self.last_response = response.body
      Nori.new(advanced_typecasting: false).parse(response.body)
    end

    def invalid_read_status(status)
      status != 0 && status != 601
    end

    def map_response_by_model(response)
      result = {}
      returned_models = find_returned_models(response)
      returned_models.each { |m| result[m] = [] }

      response.each do |r|
        model = returned_models.find{|m| r.keys.include?(m)}
        result[model] << r[model]
      end

      result.map do |model, items|
        result[model] = items.flatten.compact
      end

      result
    end

    def find_returned_models(response)
      response.map do |r|
        r.keys[0]
      end.compact.uniq
    end

    def check_auth_status(response)
      raise Sinclair::OpenAirResponseUnrecognized.new(response) if response['response']['Auth'].nil?

      auth_status = response['response']['Auth']['@status'].to_i
      raise Sinclair::OpenAirUserLocked if auth_status == 416
      raise Sinclair::OpenAirAuthenticationFailure if auth_status != 0
    end

    def check_response_status(read, model)
      statuses = read.map { |r| r['@status'].to_i }
      if statuses.any? { |s| s == 1002 }
        errors = read.select{|r| r['@status'].to_i == 1002}.map{|r| r[model]['errors']}
        raise Sinclair::OpenAirInvalidData.new(errors)
      elsif statuses.any? { |s| invalid_read_status(s) }
        raise Sinclair::OpenAirResponseError.new(statuses.find { |s| invalid_read_status(s) })
      end
    end

    def get_response(template, locals = {})
      options = {request: {timeout: @timeout, open_timeout: @open_timeout}}
      begin
        locals = locals.merge(username: @username, password: @password, company: @company, client: @client, key: @key, limit: @limit)
        Faraday.new(@url, options).post('/api.pl') do |request|
          request.body = Sinclair::Request.new(template).render(locals)
          request.headers.merge!({'Accept-Encoding' => 'identity'})
          self.last_request = request.body
        end
      rescue Faraday::TimeoutError
        raise Sinclair::OpenAirResponseTimeout
      end
    end

    def log_request
      logger.debug('#' * 80)
      logger.debug('# REQUEST')
      logger.debug('#' * 80)
      logger.debug(last_request)

      logger.debug('#' * 80)
      logger.debug('# RESPONSE')
      logger.debug('#' * 80)
      logger.debug(last_response)
    end

    def wrap_response(response)
      response.is_a?(Array) ? response : [response]
    end
  end
end
