module HasFilepickerImage
  module FormBuilderHelper
    def filepicker_image_field(attribute_name, opts = {})
      filepicker_field(attribute_name, 'default', opts)
    end

    def filepicker_field(attribute_name, config_name, opts = {})
      config = Rails.application.config.has_filepicker_image

      value = object.send(attribute_name)
      options = config.get_config(config_name).deep_merge(opts)
      html_options = options[:html_options] || {}

      preview = @template.content_tag(:div, :class => 'filepicker-image', :style => (value.present? ? '' : 'display:none;')) do
        if value.present?
          # Render preview + Delete link
          thumb_url = value + "/convert?w=260&h=180"
          thumb_alt = "#{attribute_name} thumbnail"
          @template.image_tag(thumb_url, alt: thumb_alt )
        end
      end

      pick_button = @template.content_tag(:a,
        options[:pick_button_html],
        html_options.merge(
          :href  => '#',
          :style => value.present? ? 'display:none;' : '',
          :'data-action' => 'pickImage'
        )
      )

      remove_button = @template.link_to(
        options[:delete_button_html],
        '#',
        :style => value.present? ? '' : 'display:none;',
        :'data-action' => 'removeImage'
      )

      buttons = @template.content_tag(
        :div,
        pick_button + remove_button,
        :class => 'filepicker-button'
      )

      buttons + preview + ActionView::Helpers::InstanceTag.new(
        @object_name,
        attribute_name,
        @template,
        object
      ).to_input_field_tag('hidden')
    end
  end
end
