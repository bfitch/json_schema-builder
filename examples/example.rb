require_relative '../examples/iora_definitions'

schema :admission, 'API for manipulating admissions' do
  title 'Admission Resource'

  definitions do

    ref :identity => :id

    import :patient_guid, ::IoraDefinitions

    uuid :id, 'unique identifier of an admission' do
      example '6c1ced3f-b74d-435d-ac2a-a15a33ff1d80'
    end

    string :notes, 'Text describing the admission' do
      example 'Looks like they had a bad fall.'
    end

    uuid :created_by_uid, 'unique identifier of the staff_member who created the admission' do
      example '8c1ced3hb74d435dbc2aa15a33ff1d80'
    end

    uuid :updated_by_uid, 'unique identifier of the staff_member who updated the admission' do
      example '8c1ced3hb74d435dbc2aa15a33ff1d80'
    end

    string :reason, 'Text indicating why the patient is hospitalized' do
      example 'Heart attack'
    end

    enum :location_type, 'Type of facility where the patient is admitted' do
      example 'Hospital emergency'
      values [
        'inpatient_hospitalization',
        'skilled_nursing_facility',
        'observation',
        'emergency_room',
        'other'
      ]
    end

    enum :discharge_disposition, 'Description of patient discharge' do
      example 'Home'
      values [
        'not_yet_discharged',
        'skilled_nursing_facility',
        'home',
        'other'
      ]
    end
  end

  payloads do
    request :index, 'Request properties for index' do
      ref :patient_guid
      ref :location_type
      array :practice_user_uids, "Only return admissions for patients with these practice users on their care team" do
        description "unique identifier of the staff_member to query for"
        example "8c1ced3hb74d435dbc2aa15a33ff1d80"
        format "uuid"
        type "string"
      end
    end

    response :admission do
      properties do
        object(:admission) { ref(:admission => :admission) }
      end

      one_of do
        object 'A successful response' do
          required ['admission']
          properties { object(:admission) { ref(:admission => :admission) } }
        end
        object { ref(:error_response => :error_response) }
      end
    end

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
end
