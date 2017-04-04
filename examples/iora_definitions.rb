class IoraDefinitions
  def patient_guid
    Proc.new do
      string :patient_guid, 'The guid of the patient whose care plan it is' do
        example '0123456789abcdef0123456789abcdef'
      end
    end
  end
end
