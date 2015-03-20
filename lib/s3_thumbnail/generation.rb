require "mini_magick"

module S3Thumbnail
  class Generation
    def initialize(input_file)
      @input_file = input_file
    end

    def write(output_file, width, height, quality)
      resized = resize_with_crop(image, width, height, quality)
      resized.write(output_file.path)
    end

    private

    def image
      @input_file.rewind
      MiniMagick::Image.read(@input_file).tap do |i|
        i.format('jpg')
      end
    end

    def resize_with_crop(img, width, height, quality)         
      cols, rows = img[:dimensions]
      img.combine_options do |cmd|
        if width != cols || height != rows
          scale_x = width/cols.to_f
          scale_y = height/rows.to_f
          if scale_x >= scale_y
            cols = (scale_x * (cols + 0.5)).round
            rows = (scale_x * (rows + 0.5)).round
            cmd.resize "#{cols}"
          else
            cols = (scale_y * (cols + 0.5)).round
            rows = (scale_y * (rows + 0.5)).round
            cmd.resize "x#{rows}"
          end
        end
        cmd.quality quality
        cmd.gravity 'Center'
        cmd.background "rgba(255,255,255,0.0)"
        cmd.extent "#{width}x#{height}" if cols != width || rows != height
      end
      img
    end

  end
end
