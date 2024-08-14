# frozen_string_literal: true

# Helpers for working with Cocina descriptions
class CocinaDescriptionSupport
  ROLES = {
    AUTHOR: {
      value: 'author',
      code: 'aut',
      uri: 'http://id.loc.gov/vocabulary/relators/aut',
      source: {
        code: 'marcrelator',
        uri: 'http://id.loc.gov/vocabulary/relators/'
      }
    },
    PUBLISHER: {
      value: 'publisher',
      code: 'pbl',
      uri: 'http://id.loc.gov/vocabulary/relators/pbl',
      source: {
        code: 'marcrelator',
        uri: 'http://id.loc.gov/vocabulary/relators/'
      }
    }
  }.freeze

  def self.title(title:)
    [{ value: title }]
  end

  def self.person_contributor(forename:, surname:, role: :AUTHOR)
    {
      name: [
        {
          structuredValue: [
            { value: forename, type: 'forename' },
            { value: surname, type: 'surname' }
          ]
        }
      ],
      type: 'person',
      role: [ROLES.fetch(role)]
    }
  end

  def self.note(type:, value:)
    {
      type:,
      value:
    }
  end

  def self.event_date(date_type:, date_value:, type: 'deposit', date_encoding_code: 'edtf')
    {
      type:,
      date: [{
        value: date_value,
        type: date_type,
        encoding: { code: date_encoding_code }

      }]
    }
  end

  def self.event_contributor(contributor_name_value:, type: 'publication', contributor_type: 'organization',
                             role: :PUBLISHER)
    {
      type:,
      contributor: [
        {
          name: [
            {
              value: contributor_name_value
            }
          ],
          type: contributor_type,
          role: [ROLES.fetch(role)]
        }
      ]
    }
  end
end
