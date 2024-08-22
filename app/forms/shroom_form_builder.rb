# frozen_string_literal: true

# Form Builder for this application
class ShroomFormBuilder < ActionView::Helpers::FormBuilder
  def bs_text_field(method, options = {})
    append_class(options, 'form-control')
    text_field(method, options)
  end

  def bs_text_area(method, options = {})
    append_class(options, 'form-control')
    text_area(method, options)
  end

  def bs_radio_button(method, tag_value, options = {})
    append_class(options, 'form-check-input')
    radio_button(method, tag_value, options)
  end

  def bs_label(method, text = nil, options = {}, &)
    append_class(options, 'form-label')
    label(method, text, options, &)
  end

  def bs_radio_label(method, text = nil, options = {}, &)
    append_class(options, 'form-check-label')
    label(method, text, options, &)
  end

  def bs_invalid_feedback(method, options = {})
    append_class(options, 'invalid-feedback')
    @template.content_tag(:div, object.errors[method].join(', '), options)
  end

  def bs_help_text(text, options = {})
    append_class(options, 'form-text')
    @template.content_tag(:div, text, options)
  end

  private

  def append_class(options, klass)
    options[:class] = [options[:class], klass].compact.join(' ')
  end
end
