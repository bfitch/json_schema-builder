schema :admission, 'API for manipulating admissions' do
  spec 'http://json-schema.org/draft-04/hyper-schema'
  title 'Admission Resource'

  definitions do
    import :patient_guid, BaseDefinitions

    ref :identity => :id

    uuid :id, 'unique identifier of an admission' do
      example '6c1ced3f-b74d-435d-ac2a-a15a33ff1d80'
    end
    string :patient_guid, 'The guid of the patient whose care plan it is' do
      example '0123456789abcdef0123456789abcdef'
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
      values 'inpatient_hospitalization',
             'skilled_nursing_facility',
             'observation',
             'emergency_room',
             'other'
    end
    enum :discharge_disposition, 'Description of patient discharge' do
      example 'Home'
      values 'not_yet_discharged',
             'skilled_nursing_facility',
             'home',
             'other'
    end
    string :facility, 'Name of the facility where the patient is admitted' do
      example 'Blue Cross Hospital'
    end
    date :admission_date, 'Date the patient is admitted' do
      example '2012-01-01'
    end
    date :discharge_date, 'Date the patient was discharged' do
      example '2012-01-01'
      type ['date', 'null']
    end
    date_time :created_at, 'When the admission was created' do
      example '2012-01-01T12:00:00Z'
    end
    date_time :updated_at, 'When the admission was updated' do
      example '2012-01-01T12:00:00Z'
    end
    array :admissions, 'A collection of admissions' do
      ref :admission
    end
    string :error, 'An error explaining why an action failed' do
      example "Couldn't find Patient"
      min_length 1
    end
    array :errors, 'A collection of errors' do
      ref :error
    end
  end

  payloads do
    request :index, 'Request properties for index' do
      ref :patient_guid
      ref :location_type
      array :practice_user_uids, "Only return admissions for patients with these practice users on their care team" do
        description "unique identifier of the staff_member to query for"
        example "8c1ced3hb74d435dbc2aa15a33ff1d80"
        formatt "uuid"
        type "string"
      end
    end

    response :index, 'Response to an index request' do
      one_of do
        ref :admissions, 'A successful response',
          required: true,
          additional: false
        ref :errors, 'A failure response to an index request.',
          required: true,
          additional: false
      end
    end

    request :mutation, 'Expected payload to mutate an admission' do
      string :admission, required: true do
        ref :patient_guid => :patient_id
        ref :notes
        ref :reason
        ref :location_type
        ref :discharge_disposition
        ref :facility
        ref :admission_date
        ref :discharge_date
      end
    end

    response :admission do
      one_of do
        ref :admission, 'A successful response', required: true
        ref :error_response
      end
    end

    response :error do
      array :errors, required: true do
        values do
          one_of do
            string
            hash do
              string :detail
              hash :source do
                string :pointer
              end
              string :status
              string :title
            end
          end
        end
      end
    end
  end

  links do
    index '/admissions', 'Retrieve admissions' do
      request :index
      response :index
    end

    create '/admissions', 'Create a new admission' do
      request :mutation
      response :mutation
    end

    show '/admissions/:identity', 'Retrieve admissions' do
      request :admission
      response :admission

    update '/admissions/:identity', 'Retrieve an admission' do
      request :mutation
      response :admission
    end

    destroy 'Destroy an admission' {}
  end

  properties :id, :patient_guid, :created_at, :updated_at,
    :created_by_uid, :updated_by_uid, :notes, :reason,
    :location_type, :discharge_disposition, :facility,
    :admission_date, :discharge_date
end
