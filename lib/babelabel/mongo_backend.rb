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
        doc.delete("deleted")
        collection.save(doc)
      end
    end
  end

  def update(key, doc)
    collection.save(doc)
  end

  def keys
    collection.find({}, :fields => ["_id"]).collect do |row|
      row["_id"]
    end
  end

  def available_locales
    [:en, :de]
  end

  protected

  def lookup(locale, key, scope = [], options = {})
    key   = normalize_flat_keys(locale, key, scope, options[:separator])
    value = get(locale, key)

    value.tap do
      raise options[:raise].new(locale, key, options) if value.nil? and options[:raise]
    end
  end
end
