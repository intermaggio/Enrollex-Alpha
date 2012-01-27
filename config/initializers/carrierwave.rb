CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'Rackspace',
    rackspace_username: 'stythys',
    rackspace_api_key: 'a3fa42b5b85d9f69dc1c3c0f4bf28901'
  }
  config.fog_directory = 'CourseManage'
  config.fog_host = 'http://c4242148.r48.cf2.rackcdn.com'
end
