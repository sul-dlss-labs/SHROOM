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
end
