# frozen_string_literal: true

server 'sul-shroom-poc.stanford.edu', user: 'shroom', roles: %w[web app scheduler]

Capistrano::OneTimeKey.generate_one_time_key!
