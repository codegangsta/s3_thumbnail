require "s3_style"

module S3Thumbnail
  module Thumbnailable
    extend ActiveSupport::Concern

    module ClassMethods
      def has_thumbnails(attribute)
        after_commit do
          if previous_changes.include?("#{attribute}_file")
            regenerate_thumbnails_for(attribute)
          end
        end
      end
    end

    def regenerate_thumbnails_for(attribute)
      styles_method = "#{attribute}_styles".to_sym
      s3_file       = public_send(attribute.to_sym)
      styles        = public_send(styles_method)

      generate_thumbnails(s3_file, styles)
    end

    private

    def generate_thumbnails(s3_file, styles)
      return unless s3_file.exists?

      s3       = AWS::S3.new
      bucket   = s3.buckets[S3Thumbnail.config.bucket]
      original = bucket.objects[s3_file.key]

      begin
        ext   = '.jpg'
        # Grab original from S3 and store in a tmpfile
        infile = Tempfile.new('image', "tmp/", encoding: 'binary')
        original.read { |chunk| infile.write(chunk) }
        thumbnail_generation = Generation.new(infile)

        styles.each do |style, config|
          begin
            # Write the thumbnail to a tempfile
            outfile = Tempfile.new(['s3_file', ext])

            thumbnail_generation.write(outfile,
                                       config.fetch(:width),
                                       config.fetch(:height),
                                       config.fetch(:quality, 80))

            # Ensure the keyname is like _style.jpg
            key = S3Style::Url.new(s3_file.key, ext).style(style)
            # Upload the styled file back to S3
            obj = bucket.objects[key]
            obj.write(outfile, acl: :public_read, content_type: 'image/jpeg')
          ensure
            outfile.close!
          end
        end
      ensure
        infile.close!
      end
    end
  end
end
