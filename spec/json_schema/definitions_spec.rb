require 'spec_helper'

describe Definitions do
  let(:schema) { OpenStruct.new({resource: 'admission'})}
  let(:definitions) { Definitions.new(schema) }

  describe '.build' do
    describe 'ref' do
      it 'builds a ref definition' do
        output = definitions.build do
          uuid :id, "cool"
          ref :identity => :id
        end

        expect(output[:identity]).to eq({
          :$ref => "/schemata/admission#/definitions/id"
        })
      end

      context 'referenced definition is not defined' do
        it 'has no ordering dependency' do
          output = definitions.build { ref :identity => :id }

          expect(output).to eq({
            identity: { :$ref => "/schemata/admission#/definitions/id" }
          })
        end
      end
    end

    describe 'uuid' do
      it 'builds with defaults' do
        output = definitions.build  do
          uuid :id, 'unique identifier of an admission'
        end

        expect(output).to eq({
          id: {
            description: "unique identifier of an admission",
            example: "6c1ced3f-b74d-435d-ac2a-a15a33ff1d80",
            format: "uuid",
            type: ["string"]
          }
        })
      end

      it 'sets properties with a block' do
        output = definitions.build  do
          uuid :id, 'cool description' do
            example 'abc123'
          end
        end

        expect(output).to eq({
          id: {
            description: "cool description",
            example: "abc123",
            format: "uuid",
            type: ["string"]
          }
        })
      end
    end

    describe 'string' do
      it 'builds with defaults' do
        output = definitions.build  do
          string :patient_guid, 'The guid of the patient whose care plan it is'
        end

        expect(output).to eq({
          patient_guid: {
            description: 'The guid of the patient whose care plan it is',
            type: ["string"]
          }
        })
      end

      it 'sets properties with a block' do
        output = definitions.build  do
          string :patient_guid, 'The guid of the patient whose care plan it is' do
            example '0123456789abcdef0123456789abcdef'
          end
        end

        expect(output).to eq({
          patient_guid: {
            description: 'The guid of the patient whose care plan it is',
            example: '0123456789abcdef0123456789abcdef',
            type: ["string"]
          }
        })
      end
    end

    describe 'enum' do
      it 'builds a string enum' do
        output = definitions.build  do
          enum :location_type, 'Type of facility where the patient is admitted' do
            example 'emergency_room'
            values [
              'inpatient_hospitalization',
              'skilled_nursing_facility',
            ]
          end
        end

        expect(output).to eq({
          location_type: {
            description: "Type of facility where the patient is admitted",
            example: "emergency_room",
            type: ["string"],
            enum: [ "inpatient_hospitalization", "skilled_nursing_facility" ]
          }
        })
      end

      it 'inferrs the correct types' do
        output = definitions.build  do
          enum :location_type, 'Type of facility where the patient is admitted' do
            example 'emergency_room'
            values [ 'inpatient_hospitalization', 50, nil ]
          end
        end

        expect(output).to eq({
          location_type: {
            description: "Type of facility where the patient is admitted",
            example: "emergency_room",
            type: ["string", "integer", "null"],
            enum: [ "inpatient_hospitalization", 50, nil ]
          }
        })
      end

      it 'type can be specified instead of inferred' do
        output = definitions.build  do
          enum :location_type, 'Type of facility where the patient is admitted' do
            example 'emergency_room'
            type ['string', 'null']
            values [
              'inpatient_hospitalization',
              'skilled_nursing_facility',
            ]
          end
        end

        expect(output).to eq({
          location_type: {
            description: "Type of facility where the patient is admitted",
            example: "emergency_room",
            type: ["string", "null"],
            enum: [ "inpatient_hospitalization", "skilled_nursing_facility" ]
          }
        })
      end
    end

    describe 'date' do
      it 'sets the format to "date"' do
        output = definitions.build  do
          date :admission_date, 'Date the patient is admitted'
        end

        expect(output).to eq({
          admission_date: {
            description: "Date the patient is admitted",
            example: "2012-01-01",
            format: "date",
            type: ["string"]
          }
        })
      end

      describe 'overriding the type' do
        it 'sets the format to "date" and the type' do
          output = definitions.build  do
            date :admission_date, 'Date the patient is admitted' do
              type ['string', 'null']
            end
          end

          expect(output).to eq({
            admission_date: {
              description: "Date the patient is admitted",
              example: "2012-01-01",
              format: "date",
              type: ["string", "null"]
            }
          })
        end
      end
    end

    describe 'date_time' do
      it 'sets the format to "date-time"' do
        output = definitions.build do
          date_time :updated_at, 'When the admission was updated'
        end

        expect(output).to eq({
          updated_at: {
            description: "When the admission was updated",
            example: "2012-01-01T12:00:00Z",
            format: "date-time",
            type: ["string"]
          }
        })
      end
    end

    describe 'array' do
      it 'builds an array with references to items' do
        output = definitions.build do
          array :errors, 'A collection of errors' do
            ref :error
          end
        end

        expect(output).to eq({
          errors: {
            description: "A collection of errors",
            type: ["array"],
            items: {
              :$ref => "/schemata/admission#/definitions/error"
            }
          }
        })
      end

      it 'can reference its own schema' do
        output = definitions.build do
          array :admissions, 'A collection of admissions' do
            ref :admission
          end
        end

        expect(output).to eq({
          admissions: {
            description: "A collection of admissions",
            type: ["array"],
            items: {
              :$ref => "/schemata/admission"
            }
          }
        })
      end
    end

    describe 'import' do
      class IoraDefinitions
        def practice_user_uid
          Proc.new do
            string :practice_user_uid, 'The uid of a practice user' do
              example 'abc123'
            end
          end
        end
      end

      it 'ouputs the imported definitions' do
        output = definitions.build  do
          import :practice_user_uid, IoraDefinitions

          string :patient_guid, 'The guid of the patient whose care plan it is' do
            example 'abc'
          end
        end

        expect(output).to eq({
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
        })
      end
    end
  end
end
