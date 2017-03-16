require 'spec_helper'

describe JsonSchema::Builder do
  let(:builder) { JsonSchema::Builder }
  let(:hash)    { builder.to_hash }

  describe '.schema' do
    before do
      builder.schema :admission, 'API for manipulating admissions' do
        spec 'cool url'
        title 'Admissions Resource'
        definitions {}
      end
    end

    it 'returns a hash with the correct json schema properties' do
      expect(hash).to eq({
        :id => "schemata/admission",
        :type => ["object"],
        :description => "API for manipulating admissions",
        :$schema => "cool url",
        :title => "Admissions Resource",
        :definitions => {}
      })
    end
  end
end
