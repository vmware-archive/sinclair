require 'spec_helper'

describe Sinclair::OpenAirApiClient do
  subject  { Sinclair::OpenAirApiClient.new(username: 'Username', password: 'Password', company: 'Company', client: 'Client', key: 'APIKEY', limit: '5') }
  let!(:template) { "#{File.expand_path('../templates', __FILE__)}/client_request.xml.erb" }

  describe '#send_request' do
    it 'makes multiple OpenAir requests when the number of responses is greater than the limit' do
      stub_xml_request(
        request: 'all_clients_multiple_request_1',
        response: 'all_clients_multiple_response_1'
      )

      stub_xml_request(
        request: 'all_clients_multiple_request_2',
        response: 'all_clients_multiple_response_2'
      )

      stub_xml_request(
        request: 'all_clients_multiple_request_3',
        response: 'all_clients_empty_response'
      )

      response = subject.send_request(template: template, key: 'Customer')
      names = response.map { |client| client['name'] }

      expect(names).to match_array(['Blah Client', 'Client 1', 'Client 2', 'Client 3', 'Client 4', 'Client 5', 'Fancy Client'])
    end

    it 'raises a OpenAirResponseUnrecognized error when the response is malformed' do
      stub_xml_request(
        request: 'all_clients_single_request',
        response: 'all_clients_single_error'
      )

      expect {
        subject.send_request(template: template, key: 'Client')
      }.to raise_error(Sinclair::OpenAirResponseUnrecognized)
    end

    it 'raises a OpenAirUserLocked error when the response status is 416' do
      stub_xml_request(
        request: 'all_clients_single_request',
        response: 'all_clients_locked_error'
      )

      expect {
        subject.send_request(template: template, key: 'Client')
      }.to raise_error(Sinclair::OpenAirUserLocked)
    end

    it 'raises a OpenAirAuthenticationFailure error when the response status not zero' do
      stub_xml_request(
        request: 'all_clients_single_request',
        response: 'all_clients_auth_error'
      )

      expect {
        subject.send_request(template: template, key: 'Client')
      }.to raise_error(Sinclair::OpenAirAuthenticationFailure)
    end

    it 'raises a OpenAirResponseTimeout error when OpenAir times out' do
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::TimeoutError)

      expect {
        subject.send_request(template: template, key: 'Client')
      }.to raise_error(Sinclair::OpenAirResponseTimeout)
    end
  end
end
