class CocinaDescriptionSupport
  def self.title(title:)
    [ { value: title } ]
  end

  def self.person_contributor(forename:, surname:)
    {
              name: [
                {
                  structuredValue: [
                    { value: forename, type: "forename" },
                    { value: surname, type: "surname" }
                  ]
                }
              ],
              type: "person"
            }
  end

  def self.note(type:, value:)
    {
      type: type,
      value: value
    }
  end

  def self.event(type: "deposit", date_type:, date_value:, date_encoding_code: "edtf")
    {
      type: type,
      date: [ {
        value: date_value,
        type: date_type,
        encoding: { code: date_encoding_code }

      } ]
    }
  end
end
