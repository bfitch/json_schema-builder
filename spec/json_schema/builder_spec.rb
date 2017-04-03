require 'spec_helper'

describe JsonSchema::Builder do
  let(:builder) { JsonSchema::Builder }
  let(:hash)    { builder.to_hash }

  describe '.schema' do
    describe 'integration' do
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
        expect(hash).to eq({
          :id=>"schemata/admission",
          :type=>["object"],
          :description=>"API for manipulating admissions",
          :$schema=>"cool url",
          :title=>"Admissions Resource",
          :definitions=>
          {:patient_guid=>
            {:type=>["string"],
              :description=>"The guid of the patient whose care plan it is",
              :example=>"abc"}},
              :payloads=>
              {:index=>
                {:description=>"Request properties for index",
                  :type=>["object"],
                  :clinic_type=>{:$ref=>"/schemata/admission#/definitions/location_type"}}}
        })
      end
    end

    describe 'importing definitions' do
      class IoraDefinitions
        def practice_user_uid
          Proc.new do
            string :practice_user_uid, 'The uid of a practice user' do
              example 'abc123'
            end
          end
        end
      end

      before do
        builder.schema :admission, 'API for manipulating admissions' do
          spec 'cool url'
          title 'Admissions Resource'

          definitions do
            import :practice_user_uid, IoraDefinitions

            string :patient_guid, 'The guid of the patient whose care plan it is' do
               example 'abc'
             end
          end
        end
      end

      it 'ouputs the imported definitions' do
        expect(hash).to eq({
          :id=>"schemata/admission",
          :type=>["object"],
          :description=>"API for manipulating admissions",
          :$schema=>"cool url",
          :title=>"Admissions Resource",
          :definitions=> {
            :practice_user_uid=> {
              :type=>["string"],
              :description=>"The uid of a practice user",
              :example=>"abc123"
            },
            :patient_guid=> {
              :type=>["string"],
              :description=>"The guid of the patient whose care plan it is",
              :example=>"abc"
            }
          }
        })
      end
    end
  end
end
