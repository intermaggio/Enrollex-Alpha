class CourseImage < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :fog

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_to_fill: [180, 180]

  version :small do
    process resize_to_fill: [75, 75]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
