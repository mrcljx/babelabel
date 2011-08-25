class Babelabel::TranslationsController < Babelabel::ApplicationController
  unloadable

  helper_method :mongo_i18n

  def index
    @translations = mongo_i18n.collection.find({ "deleted" => nil, "_id" => { "$not" => /^(routes)|(resource)|(scopes)|(path_names)|(named_routes)/i }}).sort([["_id", 1]]).to_a

    render :layout => "babelabel/layouts/babelabel"
  end

  def delete_unseen
    mongo_i18n.keys.each do |key|
      current = mongo_i18n.collection.find_one(:_id => key)

      unless current["last_seen"]
        current["deleted"] = true
        mongo_i18n.collection.save(current)
      end
    end

    render :nothing => true
  end

  def reset_last_seen
    mongo_i18n.keys.each do |key|
      current = mongo_i18n.collection.find_one(:_id => key)
      current.delete "last_seen"
      mongo_i18n.collection.save(current)
    end

    render :json => mongo_i18n.keys
  end

  def update
    key = params[:id]

    current = mongo_i18n.collection.find_one(:_id => key) or raise "not found"
    current["values"] ||= {}

    if vals = params["values"]
      if vals.include?("de")
        current["values"]["de"] = vals["de"]
      end

      if vals.include?("en")
        current["values"]["en"] = vals["en"]
      end
    end

    if params.include?("hidden")
      current["hidden"] = [1, true, "1", "true", "yes"].include?(params["hidden"])
    end

    mongo_i18n.collection.save(current)

    render :json => mongo_i18n.keys
  end

  protected

  def mongo_i18n
    @mongo_i18n ||= I18n.backend.backends.detect do |backend|
      backend.is_a?(Babelabel::MongoBackend)
    end
  end

end