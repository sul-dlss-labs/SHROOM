# frozen_string_literal: true

SdrClient::RedesignedClient.configure(
  url: Settings.sdr_api.url,
  email: Settings.sdr_api.email,
  password: Rails.application.credentials.dig(:sdr_api, :password)
)
