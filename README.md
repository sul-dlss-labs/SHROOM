# SHROOM (Service Helping get Research Online and Open with Machine learning)

***"Have you tried SHROOM? It's magic!"***

SHROOM is a proof-of-concept Rails application to explore:
* The use of the [GROBID](https://github.com/kermitt2/grobid) machine learning library to extract bibliographic metadata from scholarly articles to minimize manual entry by users.
* The use of SDR / DSA for the persistence of Cocina model digital objects to avoid synchronization problems between the deposit application and the repository.

## Local development
To start a local database, as well as required SDR applications: `docker compose up`.

### Helpful development tasks
Seed a collection: `bin/rake development:seed_collection`

Completing accessioning for a work: `bin/rake "development:accession[druid:ft277ns6842]"`

Cleaning up orphaned work files: `bin/rails runner "WorkFile.where(work:nil).where('created_at < ?', 1.week.ago).destroy_all"`

### Grobid
By default the Grobid container is configured to use the faster, less accurate Wapiti CRF models. See `compose.yaml` for how to switch to the DeLFT deep learning models.

## Deployment
```
cap poc deploy
```

Note that SHROOM doesn't currently use shared configs or Vault. Instead settings are in `config/settings/production.yml` and `config/credentials/production.yml.enc`.

## Helpful task
Export the metadata for a collection to CSV: `bin/rake "export_csv[druid:jk956kb4381]"`