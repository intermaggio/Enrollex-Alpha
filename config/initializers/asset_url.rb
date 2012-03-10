ASSET_URL =
  if Rails.env == 'production'
    'http://assets.enrollex.org'
  else
    'http://staging_assets.enrollex.org'
  end
