module HasFilepickerImage
  module Base
    extend ActiveSupport::Concern

    module ClassMethods

      def has_filepicker_image(name, options = {})
        cattr_accessor :has_filepicker_image_styles
        self.has_filepicker_image_styles ||= {}
        self.has_filepicker_image_styles.merge!(name.to_sym => options[:styles])

        define_method name do |*args|
          HasFilepickerImageUrlService.new(
            name:   name,
            url:    read_attribute("#{name}_url"),
            styles: self.class.has_filepicker_image_styles[name],
            args:   args
          ).url
        end
      end

      class HasFilepickerImageUrlService
        def initialize(params)
          @name     = params[:name]
          @base_url = params[:url]
          @styles   = params[:styles]
          @options  = parse_args(*params[:args])
        end

        def url
          replace_asset_host(@base_url) + conversion_component if @base_url.present?
        end

        private

        def replace_asset_host(url)
          asset_host = Rails.application.config.has_filepicker_image.asset_host
          if asset_host
            uri = URI(url)
            uri.host = asset_host
            uri.to_s
          else
            url
          end
        end

        def parse_args(*args)

          result = {}

          if args.size > 2
            raise 'Wrong number of arguments' if args.size > 2
          elsif args.size > 0
            arg = args[0]
            if arg.is_a?(Hash)
              result = arg
            else
              result = args[1] || {}
              result[:w] = @styles[arg][0]
              result[:h] = @styles[arg][1]
            end
            result[:fit] ||= 'max'
            result[:dl]  ||= 'false'
            result.assert_valid_keys(:w, :h, :fit, :dl)
          end

          result
        end

        def conversion_component
          @options.empty? ? '' : '/convert?' + @options.map { |k,v| "#{k}=#{v}" }.join('&')
        end
      end

    end

  end
end