# SHROOM (Service Helping get Research Online and Open with Machine learning)

***"Have you tried SHROOM? It's magic!"***

SHROOM is a proof-of-concept Rails application to explore:
* The use of the [GROBID](https://github.com/kermitt2/grobid) machine learning library to extract bibliographic metadata from scholarly articles to minimize manual entry by users.
* The use of SDR / DSA for the persistence of Cocina model digital objects to avoid synchronization problems between the deposit application and the repository.

## Local development
To start a local database, as well as required SDR applications: `docker compose up`.

## Deployment
```
cap poc deploy
```

Note that SHROOM doesn't currently use shared configs or Vault. Instead settings are in `config/settings/production.yml` and `config/credentials/production.yml.enc`.
