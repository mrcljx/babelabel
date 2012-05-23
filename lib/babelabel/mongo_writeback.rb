class Babelabel::MongoWriteback
  include I18n::Backend::Base, I18n::Backend::Flatten

  attr_reader :collection

  def initialize(collection)
    @collection = collection
  end

  def store_default_translations(locale, key, options = {})
    count, scope, default, separator = options.values_at(:count, :scope, :default, :separator)
    default = default.last if default.is_a?(Array)
    key = normalize_flat_keys(locale, key, scope, options[:separator])
    keys = [key]

    if count
      keys = %w(zero one other).map do |k|
        [key, k].join(".")
      end
    end

    interpolations = options.keys - I18n::RESERVED_KEYS

    keys.each do |key|
      store_default_translation locale, key, default, interpolations
    end
  end

  def store_default_translation(locale, key, default, interpolations)
    current = collection.find_one(:_id => key.to_s) || { "_id" => key.to_s }
    current["values"] ||= {}
    current["values"]["de"] ||= nil
    current["values"]["en"] ||= nil
    current["default"] = default
    current["interpolations"] = interpolations
    current["last_seen"] = Time.now.xmlschema
    collection.save(current)
  end

  protected

  def lookup(locale, key, scope = [], options = {})
    keys = normalize_flat_keys locale, key, scope, options[:separator]
    store_default_translations locale, key, options
    nil
  end
end