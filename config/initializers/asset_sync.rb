if defined?(AssetSync)
  AssetSync.configure do |config|
    config.fog_provider = ENV['FOG_PROVIDER']
    config.aws_access_key_id = ENV['AWS_ACCESS_KEY']
    config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    config.fog_directory = ENV['FOG_DIRECTORY']
    config.fog_region = ENV['FOG_REGION']

    # Don't delete files from the store
    config.existing_remote_files = "delete"

    # Automatically replace files with their equivalent gzip compressed version
    config.gzip_compression = true

    # Use the Rails generated 'manifest.yml' file to produce the list of files to
    # upload instead of searching the assets directory.
    config.manifest = true

    config.custom_headers = { '.*' => { cache_control: 'max-age=31536000', expires: 1.year.from_now.httpdate } }
  end
end
