Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GKEY, GSECRET, { approval_prompt: '', scope: 'https://www.googleapis.com/auth/calendar,userinfo.email' }
end
