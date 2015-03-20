require 'spec_helper'

class ThumbnailableSpecTarget
  extend ActiveModel::Callbacks
  extend S3Direct::Uploadable
  include S3Thumbnail::Thumbnailable

  define_model_callbacks :commit
  has_s3_file :avatar, "thumbs"
  has_thumbnails :avatar

  def avatar_file
    @avatar_file ||= "#{uuid}.png"
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end

  def avatar_styles
    {
      :small => { width: 36, height: 36 },
      :large => { width: 90, height: 90 }
    }
  end

  def commit
    run_callbacks :commit
  end

  attr_writer :previous_changes
  def previous_changes
    @previous_changes || ['avatar_file']
  end
end

describe S3Thumbnail::Thumbnailable do
  before do
    avatar_path = File.expand_path("../../../fixtures/avatar.png", __FILE__)

    @model = ThumbnailableSpecTarget.new

    s3 = AWS::S3.new(s3_endpoint: 'localhost', s3_port: '5678',
                     use_ssl: false, s3_force_path_style: true)
    @bucket = s3.buckets.create('specs')

    # Upload the file
    key = File.join(@model.avatar.key)
    obj = @bucket.objects[key]
    obj.write(Pathname.new(avatar_path))
  end

  it "generates .jpg thumbnails when the attribute_file changes" do
    @model.commit

    # Check the small image
    small = @bucket.objects["thumbs/#{@model.uuid}_small.jpg"]
    tmpfile = Tempfile.new(['small', '.jpg'], "tmp/", encoding: 'binary')
    small.read { |chunk| tmpfile.write(chunk) }
    tmpfile.rewind

    image = MiniMagick::Image.read(tmpfile)
    expect(image['format']).to eq('JPEG')
    expect(image['dimensions']).to eq([36, 36])

    # Check the large image
    large = @bucket.objects["thumbs/#{@model.uuid}_large.jpg"]
    tmpfile = Tempfile.new(['large', '.jpg'], "tmp/", encoding: 'binary')
    large.read { |chunk| tmpfile.write(chunk) }
    tmpfile.rewind

    image = MiniMagick::Image.read(tmpfile)
    expect(image['format']).to eq('JPEG')
    expect(image['dimensions']).to eq([90, 90])
  end

  it "sets the content type to 'image/jpeg'" do
    @model.commit
    small = @bucket.objects["thumbs/#{@model.uuid}_small.jpg"]
    large = @bucket.objects["thumbs/#{@model.uuid}_large.jpg"]

    expect(small.content_type).to eq('image/jpeg')
    expect(large.content_type).to eq('image/jpeg')
  end

  it "skips generation if the attribute_file is unchanged" do
    AWS::S3.should_not_receive(:new)
    @model.previous_changes = []
    @model.commit
  end

  it "skips generation if the attribute_file is changed to blank" do
    @model.stub(:avatar_file).and_return(nil)
    AWS::S3.should_not_receive(:new)
    @model.commit
  end

  it "can generate a thumbnail on demand with #regenerate_thumbnails_for" do
    @model.regenerate_thumbnails_for(:avatar)

    small = @bucket.objects["thumbs/#{@model.uuid}_small.jpg"]
    tmpfile = Tempfile.new(['small', '.jpg'], "tmp/", encoding: 'binary')
    small.read { |chunk| tmpfile.write(chunk) }
    expect(tmpfile.size).to be_present

    # Check the large image
    large = @bucket.objects["thumbs/#{@model.uuid}_large.jpg"]
    tmpfile = Tempfile.new(['large', '.jpg'], "tmp/", encoding: 'binary')
    large.read { |chunk| tmpfile.write(chunk) }
    expect(tmpfile.size).to be_present
  end
end
