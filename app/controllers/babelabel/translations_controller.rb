class Babelabel::TranslationsController < Babelabel::ApplicationController
  unloadable

  helper_method :mongo_i18n

  def index
    @translations = mongo_i18n.collection.find({ "_id" => { "$not" => /^(routes)|(resource)|(scopes)|(path_names)|(named_routes)/i }}).sort([["_id", 1]]).to_a

    render :layout => "babelabel/layouts/babelabel"
  end

  def delete_unseen
    mongo_i18n.keys.each do |key|
      current = mongo_i18n.collection.find_one(:_id => key)

      unless current["last_seen"]
        mongo_i18n.collection.remove({ :_id => key })
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

    if de_value = params["value"]["de"]
      current["values"]["de"] = de_value
    end

    if en_value = params["value"]["en"]
      current["values"]["en"] = en_value
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