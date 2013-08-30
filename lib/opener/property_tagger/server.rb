require 'sinatra/base'
require 'httpclient'
require 'opener/webservice'

module Opener
  class PropertyTagger
    ##
    # Property tagger server powered by Sinatra.
    #
    class Server < Webservice
      set :views, File.expand_path('../views', __FILE__)
      text_processor PropertyTagger
      accepted_params :input
    end # Server
  end # PropertyTagger
end # Opener
