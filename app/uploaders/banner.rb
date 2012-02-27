class Banner < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_to_limit: [800, 200]
  process :store_geometry
  def store_geometry
    if @file
      img = ::Magick::Image::read(@file.file).first
      if model
        model.banner_height = img.rows
      end
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
