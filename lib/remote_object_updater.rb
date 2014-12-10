class RemoteObjectUpdater

  def initialize(json, object)
    @json   = json
    @object = object
  end

  def import!
    object_class    = @object.class.to_s.underscore
    object_as_json  = filter(parsed_json[object_class], object_class)

    @object.update_attributes object_as_json
  end

  private

  def filter(json_in, klass)
    json_out              = Hash.new
    json_object_all_keys  = [class_reflections_filter(klass), class_attribute_filter(klass)].flatten

    json_in.reject { |key, value| !json_object_all_keys.include?(key) }.
      each { |key, value|
        if value.is_a?(Array)
          object_array = value.map { |hash| filter(hash, key) }

          json_out.merge! Hash["#{key}_attributes", object_array]
        else
          json_out.merge! Hash[key, value]
        end
      }

    json_out
  end

  def class_attribute_filter(klass)
    klazz       = klass.classify.constantize
    instance    = klazz.new
    attributes  = instance.attributes.keys

    attributes.delete_if { |attribute| universal_attribute_filter.include?(attribute) }
  end

  def class_reflections_filter(klass)
    klass.classify.constantize.reflections.keys.map(&:to_s)
  end

  def universal_attribute_filter
    ['id', 'created_at', 'updated_at', 'deleted_at']
  end

  def parsed_json
    @parsed_json ||= Yajl::Parser.parse @json
  end
end