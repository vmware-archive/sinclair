require 'spec_helper'

describe Sinclair::OpenAirApiClient do
  subject  { Sinclair::OpenAirApiClient.new(username: 'Username', password: 'Password', company: 'Company', client: 'Client', key: 'APIKEY', limit: '5') }
  let!(:template_path) { "#{File.expand_path('../templates', __FILE__)}/client_request.xml.erb" }

  describe '#send_request' do
    let(:template) {IO.read(template_path)}
    before do
      stub_xml_request(
        request: 'all_clients_multiple_request_1',
        response: 'all_clients_multiple_response_1'
      )

      stub_xml_request(
        request: 'all_clients_multiple_request_2',
        response: 'all_clients_multiple_response_2'
      )
    end

    it 'accepts file content as a string (not file paths)' do
      test_actions = lambda { subject.send_request(template: template, key: 'Customer') }

      expect(test_actions).not_to raise_exception
    end

    it 'allows a user to pass in "locals"' do
      arguments = {
        template: 'im a template',
        key: 'Customer',
        locals: {
          name: 'bar',
          id: 'foo'
        }
      }

      expect(subject).to receive(:process_page).with('im a template', 'Customer', {offset: 0, name: 'bar', id: 'foo'} ).and_return([])

      subject.send_request(arguments)
    end

    it 'makes multiple OpenAir requests when the number of responses is greater than the limit' do
      response = subject.send_request(template: template, key: 'Customer')
      names = response.map { |client| client['name'] }

      expect(names).to match_array(['Blah Client', 'Client 1', 'Client 2', 'Client 3', 'Client 4', 'Client 5', 'Fancy Client'])
    end
  end

  describe 'OpenAir Errors' do
    let(:template) {IO.read(template_path)}

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

    it 'raises a OpenAirResponseError when the read status is not zero' do
      stub_xml_request(
        request: 'all_clients_single_request',
        response: 'all_clients_read_error'
      )

      expect {
        subject.send_request(template: template, key: 'Client')
      }.to raise_error(Sinclair::OpenAirResponseError, 'Error making OpenAir request for Client. Got status 602.')
    end

    it 'does not raise an error when the read status is 601' do
      stub_xml_request(
        request: 'all_clients_single_request',
        response: 'all_clients_read_601_error'
      )

      expect {
        subject.send_request(template: template, key: 'Client')
      }.not_to raise_error
    end
  end
end
