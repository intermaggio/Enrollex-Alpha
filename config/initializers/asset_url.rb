ASSET_URL =
  if Rails.env == 'production'
    'http://assets.enrollex.org'
  elsif Rails.env == 'staging'
    'http://staging_assets.enrollex.org'
  else
    'http://localhost:3000'
  end
