class CocinaSupport
  def self.pretty(cocina_object:)
    JSON.pretty_generate(clean(cocina_object.to_h))
  end

  def self.clean(obj)
    if obj.is_a?(Hash)
      obj.each { |k, v| clean(v) }
      obj.delete_if { |k, v| v.respond_to?(:empty?) && v.empty? }
    elsif obj.is_a?(Array)
      obj.each { |v| clean(v) }
      obj.delete_if { |v| v.respond_to?(:empty?) && v.empty? }
    end
    obj
  end
  private_class_method :clean
end
