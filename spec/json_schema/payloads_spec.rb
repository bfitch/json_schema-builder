require 'spec_helper'

describe Payloads do
  let(:schema) { OpenStruct.new({resource: 'admission'})}
  let(:payloads) { Payloads.new(schema) }

  describe '.build' do
    describe 'request' do
      it 'builds an array with references to items' do
        output = payloads.build do

          request :index, 'Request properties for index' do
            properties do
              ref :location_type => :location_type

              array :practice_user_uids, "Only return admissions for patients with these practice users on their care team" do
                description "unique identifier of the staff_member to query for"
                example "8c1ced3hb74d435dbc2aa15a33ff1d80"
                format "uuid"
                type "string"
              end
            end
          end

        end

        expect(output).to eq({
          index: {
            description: "Request properties for index",
            type: [ "object" ],
            properties: {
              location_type: { :$ref => "/schemata/admission#/definitions/location_type" },
              practice_user_uids: {
                description: "Only return admissions for patients with these practice users on their care team",
                type: ["array"],
                items: {
                  description: "unique identifier of the staff_member to query for",
                  example: "8c1ced3hb74d435dbc2aa15a33ff1d80",
                  format: "uuid",
                  type: "string"
                }
              }
            }
          }
        })
      end
    end

    describe 'response' do
      it 'builds a response object' do
        output = payloads.build do

          response :index, 'Response to an index request' do
            properties { ref :admissions => :admissions }

            one_of do
              object 'A successful response' do
                required ['admissions']
                additional_properties false
                properties { ref :admissions => :admissions }
              end

              object 'A failure response to an index request' do
                required ['errors']
                additional_properties false
                properties { ref :errors => :errors }
              end
            end
          end
        end

        expect(output).to eql({
          :index=>
          {:description=>"Response to an index request",
            :type=>["object"],
            :properties=>
            {:admissions=>{:$ref=>"/schemata/admission#/definitions/admissions"}},
            :oneOf=>
            [{:description=>"A successful response",
              :type=>["object"],
              :required=>["admissions"],
              :additionalProperties=>false,
              :properties=>{:admissions=>{:$ref=>"/schemata/admission#/definitions/admissions"}}},
              {:description=>"A failure response to an index request",
                :type=>["object"],
                :required=>["errors"],
                :additionalProperties=>false,
                :properties=>{:errors=>{:$ref=>"/schemata/admission#/definitions/errors"}}}]}
        })
      end

      it 'builds another response' do
        output = payloads.build do

          response :admission do
            properties do
              object(:admission) { ref :admission => :admission }
            end

            one_of do
              object 'A successful response' do
                required ['admission']
                properties { ref :admission => :admission }
              end

              object { ref :error_response }
            end
          end

        end

        expect(output).to eq({
          :admission=>
          {:type=>["object"],
            :properties=>
            {:admission=>
              {:type=>["object"], :admission=>{:$ref=>"/schemata/admission"}}},
              :oneOf=>
              [{:type=>["object"],
                :description=>"A successful response",
                :required=>["admission"],
                :properties=>{:admission=>{:$ref=>"/schemata/admission"}}},
                {:type=>["object"],
                  :$ref=>"/schemata/admission#/definitions/error_response"}]}
        })
      end
    end

    describe 'mutation request' do
      it 'builds the request object' do
        output = payloads.build do

          request :mutation, 'Expected payload to mutate an admission' do
            required ['admission']
            properties do
              object :admission do
                properties do
                  ref :patient_guid => :patient_gui
                  ref :notes => :notes
                  ref :reason => :reason
                  ref :location_type => :location_type
                  ref :discharge_disposition => :discharge_disposition
                  ref :facility => :facility
                  ref :admission_date => :admission_date
                  ref :discharge_date => :discharge_date
                end
              end
            end
          end
        end

        expect(output).to eq({
          :mutation=>
            {:description=>"Expected payload to mutate an admission",
              :type=>["object"],
              :required=>["admission"],
              :properties=>
              {:admission=>
                {:type=>["object"],
                 :properties=>
                 {:patient_guid=>
                   {:$ref=>"/schemata/admission#/definitions/patient_gui"},
                   :notes=>{:$ref=>"/schemata/admission#/definitions/notes"},
                   :reason=>{:$ref=>"/schemata/admission#/definitions/reason"},
                   :location_type=> {:$ref=>"/schemata/admission#/definitions/location_type"},
                   :discharge_disposition=> {:$ref=>"/schemata/admission#/definitions/discharge_disposition"},
                   :facility=>{:$ref=>"/schemata/admission#/definitions/facility"},
                   :admission_date=> {:$ref=>"/schemata/admission#/definitions/admission_date"},
                   :discharge_date=> {:$ref=>"/schemata/admission#/definitions/discharge_date"}}}}}

        })
      end
    end

    describe 'error response' do
      it 'builds an error schema' do
        output = payloads.build do

          response :error do
            required ['errors']
            properties do
              array :errors do
                one_of do
                  string
                  object do
                    properties do
                      string :detail
                      object(:source) { properties { string :pointer } }
                      string :status
                      string :title
                    end
                  end
                end
              end
            end
          end
        end

        expect(output).to eq({
          :error=> {
            :type=>["object"],
            :required=>["errors"],
            :properties=> {
              :errors=> {
                :type=>["array"],
                :items=> {
                  :oneOf=> [{
                    :type=>["string"]
                  },
                  {
                    :type=>["object"],
                    :properties=> {
                      :detail=>{
                        :type=>["string"]
                      },
                      :source=> {
                        :type=>["object"],
                        :properties=>{
                          :pointer=>{
                            :type=>["string"]
                          }
                        }
                      },
                      :status=>{
                        :type=>["string"]
                      },
                      :title=>{
                        :type=>["string"]
                      }
                    }
                  }]
                }
              }
            }
          }
        })
      end
    end

  end
end
