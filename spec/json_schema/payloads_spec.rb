require 'spec_helper'
require 'ostruct'
require 'pp'

describe Payloads do
  let(:schema) { OpenStruct.new({resource: 'admission'})}
  let(:payloads) { Payloads.new(schema) }

  describe '.build' do
    describe 'array' do
      it 'builds an array with references to items' do
        output = payloads.build do
          request :index, 'Request properties for index' do
            ref :location_type => :location_type
            array :practice_user_uids, "Only return admissions for patients with these practice users on their care team" do
              description "unique identifier of the staff_member to query for"
              example "8c1ced3hb74d435dbc2aa15a33ff1d80"
              format "uuid"
              type "string"
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
  end
end
