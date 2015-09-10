$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'sinclair'
require 'webmock'

WebMock.disable_net_connect!(allow_localhost: true, allow: 'codeclimate.com')

def ignore_whitespace(str)
  str.gsub(/\s/, '')
end

def xml_fixture_for(file)
  File.read(File.join('spec', 'fixtures', "#{file}.xml"))
end

def stub_xml_request(options = {})
  request = ignore_whitespace(xml_fixture_for(options[:request]))
  response = xml_fixture_for(options[:response])

  WebMock.stub_request(:post, 'https://www.openair.com/api.pl').with do |r|
    ignore_whitespace(r.body) == request
  end.to_return(status: 200, body: response)
end
