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

## Creating a question / answer dataset
Note:
* The first time this is run, all of the PDFs will be downloaded from Google Cloud Storage.
* Entries that are not articles and published before 2019 are filtered.

### Prerequisites
#### Install pdfalto
```
brew install cmake
brew install automake
brew install wget
git clone https://github.com/kermitt2/pdfalto.git
cd pdfalto
git submodule update --init --recursive
mkdir libs/freetype/mac/arm64
mkdir libs/icu/mac/arm64
mkdir libs/libxml/mac/arm64
mkdir libs/image/png/mac/arm64
mkdir libs/image/zlib/mac/arm64
./install_deps.sh
export C_INCLUDE_PATH=/opt/homebrew/include
export CPLUS_INCLUDE_PATH=/opt/homebrew/include
cmake .
make
```

#### Download preprints metadata
Available from https://storage.cloud.google.com/cloud-ai-platform-e215f7f7-a526-4a66-902d-eb69384ef0c4/preprints/metadata.jsonl

### Generate summary
```
bin/rails runner "pp Dataset::Analyzer.summarize"

{"title"=>{:total=>10782, :matches=>7338, :matches_articles=>7329},
 "author"=>{:total=>125923, :matches=>97017, :matches_articles=>10188},
 "all_authors"=>{:total=>10782, :matches=>6850, :matches_articles=>6841},
 "affiliation"=>{:total=>82581, :matches=>31161, :matches_articles=>5272},
 "all_affiliations_for_author"=>{:total=>125923, :matches=>47202, :matches_articles=>4967},
 "all_affiliations"=>{:total=>10782, :matches=>1818, :matches_articles=>1815},
 "abstract"=>{:total=>10782, :matches=>512, :matches_articles=>512}}
```

### Generate dataset
```
bin/rails runner "Dataset::Analyzer.question_dataset(output_filepath: 'question_dataset.jsonl')"

head -1 question_dataset.jsonl | jq
{
  "filename": "www.biorxiv.org/W3164692211.pdf",
  "question": "What is the title?",
  "answer": "Integrated analysis of multimodal single-cell data",
  "field": "title"
}
```