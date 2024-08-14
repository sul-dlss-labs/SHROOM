class ShroomFormBuilder < ActionView::Helpers::FormBuilder
  def bs_text_field(method, options = {})
    append_class(options, "form-control")
    text_field(method, options)
  end

  def bs_text_area(method, options = {})
    append_class(options, "form-control")
    text_area(method, options)
  end

  def bs_label(method, options = {})
    append_class(options, "form-label")
    label(method, options)
  end

  def bs_invalid_feedback(method, options = {})
    append_class(options, "invalid-feedback")
    @template.content_tag(:div, object.errors[method].join(", "), options)
  end

  private

  def append_class(options, klass)
    options[:class] = [ options[:class], klass ].compact.join(" ")
  end
end
