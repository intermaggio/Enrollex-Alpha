class CourseImage < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :small do
    process resize_to_fit: [75, 75]
  end

  version :large do
    process resize_to_fit: [180, 180]
  end

  version :slider do
    process resize_to_fit: [700, 470]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
