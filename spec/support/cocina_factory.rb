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
                                                      ],
                                                      orcid: 'https://orcid.org/0000-0003-1527-0030'),
          CocinaDescriptionSupport.person_contributor(forename: 'Lynn',
                                                      surname: 'Connaway')
        ],
        note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract_fixture)],
        event: [
          CocinaDescriptionSupport.event_date(date_type: 'publication',
                                              date_value: '2004-10-01'),
          CocinaDescriptionSupport.event_contributor(contributor_name_value: 'American Library Association')
        ],
        subject: CocinaDescriptionSupport.subjects(values: ['Electronic books', 'Academic libraries']),
        relatedResource: [CocinaDescriptionSupport.related_resource_note(citation: citation_fixture)]
      },
      version: 1,
      identification: { sourceId: 'shroom:object-0' },
      administrative: { hasAdminPolicy: Settings.apo },
      access: { view: 'world', download: 'world' },
      structural: { contains: [], isMemberOf: [collection_druid_fixture] }
    }
  )
end

# rubocop:disable Metrics/AbcSize
def create_dro
  Cocina::Models.build(
    {
      externalIdentifier: druid_fixture,
      type: Cocina::Models::ObjectType.object,
      label: title_fixture,
      description: {
        purl: Sdr::Purl.from_druid(druid: druid_fixture),
        title: CocinaDescriptionSupport.title(title: title_fixture),
        contributor: [
          CocinaDescriptionSupport.person_contributor(forename: 'Justin',
                                                      surname: 'Littman',
                                                      affiliations: [
                                                        {
                                                          organization: 'Library of Congress',
                                                          department: 'Repository Development Center'
                                                        }
                                                      ],
                                                      orcid: 'https://orcid.org/0000-0003-1527-0030'),
          CocinaDescriptionSupport.person_contributor(forename: 'Lynn',
                                                      surname: 'Connaway')
        ],
        note: [CocinaDescriptionSupport.note(type: 'abstract', value: abstract_fixture)],
        event: [
          CocinaDescriptionSupport.event_date(date_type: 'publication',
                                              date_value: '2004-10-01'),
          CocinaDescriptionSupport.event_contributor(contributor_name_value: 'American Library Association')
        ],
        subject: CocinaDescriptionSupport.subjects(values: ['Electronic books', 'Academic libraries']),
        relatedResource: [CocinaDescriptionSupport.related_resource_note(citation: citation_fixture)]
      },
      version: 2,
      identification: { sourceId: 'shroom:object-4' },
      administrative: { hasAdminPolicy: Settings.apo },
      access: { view: 'world', download: 'world' },
      structural: { contains: [], isMemberOf: [collection_druid_fixture] }
    }
  )
end

def create_dro_with_structural
  create_dro.new(structural: {
                   contains: [
                     {
                       type: 'https://cocina.sul.stanford.edu/models/resources/file',
                       externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
                       label: 'preprint.pdf',
                       version: 1,
                       structural: {
                         contains: [
                           {
                             type: 'https://cocina.sul.stanford.edu/models/file',
                             externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/preprint.pdf',
                             label: 'preprint.pdf',
                             filename: 'preprint.pdf',
                             size: 204_615,
                             version: 1,
                             hasMimeType: 'application/pdf',
                             sdrGeneratedText: false,
                             correctedForAccessibility: false,
                             hasMessageDigests: [
                               {
                                 type: 'md5',
                                 digest: '46b763ec34319caa5c1ed090aca46ef2'
                               },
                               {
                                 type: 'sha1',
                                 digest: 'd4f94915b4c6a3f652ee7de8aae9bcf2c37d93ea'
                               }
                             ],
                             access: {
                               view: 'world',
                               download: 'world',
                               controlledDigitalLending: false
                             },
                             administrative: {
                               publish: true,
                               sdrPreserve: true,
                               shelve: true
                             }
                           }
                         ]
                       }
                     }
                   ],
                   isMemberOf: [collection_druid_fixture]
                 })
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
