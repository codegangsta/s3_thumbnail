require 'spec_helper'

describe S3Thumbnail::Generation do
  it "can resize an image file down to a given width and height" do
      avatar_paths = [
        File.expand_path("../fixtures/avatar.jpg", __FILE__),
        File.expand_path("../fixtures/avatar.png", __FILE__)
      ]

      avatar_paths.each do |path|
        begin
          input       = File.open(path, "rb")
          output      = Tempfile.new(['spec_avatar', '.jpg'])

          S3Thumbnail::Generation.new(input).write(output, 42, 42, 80)

          image = MiniMagick::Image.read(output)
          expect(image[:dimensions]).to eq([42, 42])
          expect(image[:format]).to eq('JPEG')
        ensure
          output.close
        end

      end
  end
end
