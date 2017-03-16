require 'spec_helper'
require 'ostruct'

describe Definitions do
  let(:schema) { OpenStruct.new({resource: 'admission'})}
  let(:definitions) { Definitions.new(schema) }

  describe '.build' do
    describe 'ref' do
      it 'builds a ref definition' do
        output = definitions.build do
          uuid :id, "cool"
          ref :identity, :references => :id
        end

        expect(output[:identity]).to eq({
          :$ref => "/schemata/admission#/definitions/id"
        })
      end

      context 'referenced definition is not defined' do
        it 'raises a helpful error' do
          expect {
            definitions.build { ref :identity, :references => :id }
          }.to raise_error(RuntimeError, "Missing definition: id")
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
            format: "uuid",
            type: "string"
          }
        })
      end

      it 'sets properties with a block' do
        output = definitions.build  do
          uuid :id, 'cool description' do
            example '6c1ced3f-b74d-435d-ac2a-a15a33ff1d80'
          end
        end

        expect(output).to eq({
          id: {
            description: "cool description",
            example: "6c1ced3f-b74d-435d-ac2a-a15a33ff1d80",
            format: "uuid",
            type: "string"
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
            type: "string"
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
            type: "string"
          }
        })
      end
    end
  end
end
