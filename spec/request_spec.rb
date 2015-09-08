require 'spec_helper'

describe Sinclair::Request do
  subject { Sinclair::Request.new('<Read type="Foo"><%= foo %></Read>') }

  describe '#render' do
    let(:output) { ignore_whitespace(subject.render(foo: '<name>Sinclair</name>')) }

    it 'renders the request header' do
      expect(output).to include(ignore_whitespace('<Auth><Login><company>'))
    end

    it 'renders the request body' do
      expect(output).to include(ignore_whitespace('<Read type="Foo"><name>Sinclair</name></Read>'))
    end
  end
end
