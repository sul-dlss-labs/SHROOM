# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
def create_request_dro
  Cocina::Models.build_request(
    {
      type: Cocina::Models::ObjectType.object,
      label: title_fixture,
      description: {
        title: CocinaDescriptionSupport.title(title: title_fixture),
        contributor: [
          CocinaDescriptionSupport.person_contributor(forename: 'Justin',
                                                      surname: 'Littman',
                                                      affiliations: [
                                                        {
                                                          organization: 'Library of Congress',
                                                          department: 'Repository Development Center'
                                                        }
                                                      ]),
          CocinaDescriptionSupport.person_contributor(forename: 'Lynn',
                                                      surname: 'Connaway')
        ],
        note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract_fixture)],
        event: [
          CocinaDescriptionSupport.event_date(date_type: 'publication',
                                              date_value: '2004-10-01'),
          CocinaDescriptionSupport.event_contributor(contributor_name_value: 'American Library Association')
        ],
        subject: CocinaDescriptionSupport.subjects(values: ['Electronic books', 'Academic libraries'])
      },
      version: 1,
      identification: { sourceId: 'shroom:object-0' },
      administrative: { hasAdminPolicy: Settings.apo },
      access: { view: 'world', download: 'world' }
    }
  )
end
# rubocop:enable Metrics/MethodLength
