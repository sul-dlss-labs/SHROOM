# SHROOM (Service Helping get Research Online and Open with Machine learning)

***"Have you tried SHROOM? It's magic!"***

SHROOM is a proof-of-concept Rails application to explore:
* The use of the [GROBID](https://github.com/kermitt2/grobid) machine learning library to extract bibliographic metadata from scholarly articles to minimize manual entry by users.
* The use of SDR / DSA for the persistence of Cocina model digital objects to avoid synchronization problems between the deposit application and the repository.

## Local development
To start a local database, as well as required SDR applications: `docker compose up`.

### Install LibTorch
LibTorch is used for vector lookups of research organizations.

See https://github.com/ankane/torch.rb?tab=readme-ov-file#installation

### Helpful development tasks
Seed a collection: `bin/rake development:seed_collection`

Completing accessioning for a work: `bin/rake "development:accession[druid:ft277ns6842]"`

Cleaning up orphaned work files: `bin/rails runner "WorkFile.where(work:nil).where('created_at < ?', 1.week.ago).destroy_all"`

Enabled caching of Gemini responses and affiliation searches: `bin/rails dev:cache`

### Grobid
By default the Grobid container is configured to use the faster, less accurate Wapiti CRF models. See `compose.yaml` for how to switch to the DeLFT deep learning models.

## Deployment
```
cap poc deploy
```

Note that SHROOM doesn't currently use shared configs or Vault. Instead settings are in `config/settings/production.yml` and `config/credentials/production.yml.enc`.

### Running Grobid on server
```
docker run -d --rm --init --ulimit core=0 -p 8070:8070 lfoppiano/grobid:latest-crf
```
or
```
docker run -d --rm --init --ulimit core=0 -p 8070:8070 lfoppiano/grobid:latest-full
```

### Loading ROR data
The ROR dataset can be downloaded and unzipped from https://zenodo.org/records/13357234.

```
bin/rails runner "RorEmbeddings::Loader.call(json_filepath: 'ror-data/v1.51-2024-08-21-ror-data_schema_v2.json')
```

If it crashes, loading can be continued with the resume flag.
```
bin/rails runner "RorEmbeddings::Loader.call(json_filepath: 'ror-data/v1.51-2024-08-21-ror-data_schema_v2.json', resume: true)
```

### Loading Geonames data
The Geonames dataset can be downloaded and unzipped from https://download.geonames.org/export/dump/allCountries.zip.

```
bin/rails runner "Geonames::Loader.call(path: 'allCountries.txt')"
```

## Helpful tasks
Export the metadata for a collection to CSV: `bin/rake "export:csv[druid:jk956kb4381]"`

Export the metadata for a collection to line-oriented JSON: `bin/rake "export:json[druid:jk956kb4381]"`

## Data model for an article
```
{
    "title": STRING,
    "authors": [
        {
            "first_name": STRING (REQUIRED - includes middle name, initials, etc.),
            "last_name": STRING (REQUIRED),
            "affiliations": [
                {
                    "organization": STRING (REQUIRED)
                    "ror_id": STRING
                }
            ]
        }
    ],
    "abstract": STRING,
    "keywords": [
        {
            value: STRING
        }
    ],
    "related_resource_citation": STRING,
    "related_resource_doi": STRING (for example, 10.5860/lrts.48n4.8259),
    "published": BOOLEAN,
    "collection_druid": STRING (for example, druid:jk956kb4381)
}
```

## Evaluation
To compare groundtruth metadata from a JSONL file against metadata produced by a metadata extraction service (e.g., MetadataExtractionService::Grobid):
```
bin/rails r "EvaluationRunner.call(limit: 2)"
PASS: druid:hc954ws1639
FAIL: druid:nv906wk0020 (6970.pdf)
  Authors do not match:
    expected: Victor Lee, Christine Bywater, Robert Wachtel Pronovost, Kaifeng Cheng, Daniel Guimaraes
    actual:   Victor R Lee, Christine Bywater, Robert Wachtel, Kaifeng Cheng, Daniel Guimaraes
```