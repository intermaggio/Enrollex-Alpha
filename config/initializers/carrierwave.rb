CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'Rackspace',
    rackspace_username: 'stythys',
    rackspace_api_key: ENV['RACKSPACE_KEY']
  }
  config.fog_directory = 'CourseManage'
  config.fog_host = 'http://c4242148.r48.cf2.rackcdn.com'
end
