class Babelabel::MongoBackend
  attr_reader :collection

  include I18n::Backend::Base, I18n::Backend::Flatten

  def initialize(collection, subtrees=true)
    @collection, @subtrees = collection, subtrees
  end

  def get(locale, key)
    if doc = fetch(key) and doc["values"] and doc["values"][locale.to_s]
      doc["values"][locale.to_s].to_s
    end
  end

  def fetch(key)
    collection.find_one(:_id => key.to_s).tap do |doc|
      if doc
        doc["last_seen"] = Time.now.xmlschema
        collection.save(doc)
      end
    end
  end

  def update(key, doc)
    collection.save(doc)
  end

  def store_translations(locale, data, options = {})
    escape = options.fetch(:escape, true)
    flatten_translations(locale, data, escape, @subtrees).each do |key, value|
      case value
      when Hash
        if @subtrees && (old_value = get(locale, key))
          old_value = old_value
          value = old_value.deep_symbolize_keys.deep_merge!(value) if old_value.is_a?(Hash)
        end
      when Proc
        raise "Key-value stores cannot handle procs"
      end

      set(locale, key, value) unless value.is_a?(Symbol)
    end
  end

  def keys
    collection.find({}, :fields => ["_id"]).collect do |row|
      row["_id"]
    end
  end

  def available_locales
    locales = self.keys.map { |k| k =~ /\./; $` }
    locales.uniq!
    locales.compact!
    locales.map! { |k| k.to_sym }
    locales
  end

  protected

  def lookup(locale, key, scope = [], options = {})
    key   = normalize_flat_keys(locale, key, scope, options[:separator])
    value = get(locale, key)
    value.is_a?(Hash) ? value.deep_symbolize_keys : value
  end
end
