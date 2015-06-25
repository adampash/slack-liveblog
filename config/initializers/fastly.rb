FastlyRails.configure do |c|
  c.api_key = ENV['FASTLY_API_KEY']  # Fastly api key, required
  c.max_age = 30                  # time in seconds, optional, defaults to 2592000 (30 days)
  c.service_id = ENV['FASTLY_SERVICE_ID']   # The Fastly service you will be using, required
  c.purging_enabled = !Rails.env.development? # No need to configure a client locally (AVAILABLE ONLY AS OF 0.4.0)
end
