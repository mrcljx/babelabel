require 'rdiscount'

class Babelabel::ApplicationController < ActionController::Base
  helper :all
  # protect_from_forgery

  cattr_accessor :authenticator
  before_filter :authenticate

  protected

  def authenticate
    self.authenticator.bind(self).call if self.authenticator && self.authenticator.respond_to?(:call)
  end
end