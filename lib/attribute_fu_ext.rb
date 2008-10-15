module AttributeFu::AssociatedFormHelper
  def extract_option_or_class_name(hash, option, object)
    (hash.delete(option) || object.class.base_class.name.split('::').last.underscore).to_s
  end
end