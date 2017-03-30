require 'spec_helper'

describe JsonSchema::Builder do
  let(:builder) { JsonSchema::Builder }
  let(:hash)    { builder.to_hash }

  describe '.schema' do
    before do
      builder.schema :admission, 'API for manipulating admissions' do
        spec 'cool url'
        title 'Admissions Resource'
        definitions do
          string :patient_guid, 'The guid of the patient whose care plan it is' do
             example 'abc'
           end
        end
        payloads do
          request :index, 'Request properties for index' do
            ref :clinic_type => :location_type
          end
        end
      end
    end

    it 'returns a hash with the correct json schema properties' do
      expect(hash).to eq(
        {:id=>"schemata/admission",
         :type=>["object"],
         :description=>"API for manipulating admissions",
         :$schema=>"cool url",
         :title=>"Admissions Resource",
         :definitions=>
          {:patient_guid=>
            {:description=>"The guid of the patient whose care plan it is",
             :example=>"abc",
             :type=>["string"]}},
         :payloads=>
          {:index=>
            {:description=>"Request properties for index",
             :type=>["object"],
             :properties=>
              {:clinic_type=>
                {:$ref=>"/schemata/admission#/definitions/location_type"}}}}}
      )
    end
  end
end
