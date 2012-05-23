class Babelabel::MongoWriteback
  include I18n::Backend::Base, I18n::Backend::Flatten

  attr_reader :collection

  def initialize(collection)
    @collection = collection
  end

  def store_default_translations(locale, key, options = {})
    count, scope, default, separator = options.values_at(:count, :scope, :default, :separator)
    separator ||= I18n.default_separator
    key = normalize_flat_keys(locale, key, scope, separator)

    interpolations = options.keys - I18n::RESERVED_KEYS
    keys = count ? I18n.t('i18n.plural.keys', :locale => locale).map { |k| [key, k].join(".") } : [key]
    keys.each { |key| store_default_translation(locale, key, default, interpolations) }
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
    key = normalize_flat_keys(locale, key, scope, options[:separator])
    self.store_default_translations(locale, key, options)

    if options.include?(:default)
      options[:default]
    elsif options[:raise]
      raise options[:raise].new(locale, key, options)
    end
  end
end