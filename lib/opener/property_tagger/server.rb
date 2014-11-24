require 'opener/webservice'

module Opener
  class PropertyTagger
    ##
    # Property tagger server powered by Sinatra.
    #
    class Server < Webservice::Server
      set :views, File.expand_path('../views', __FILE__)

      self.text_processor  = PropertyTagger
      self.accepted_params = [:input]
    end # Server
  end # PropertyTagger
end # Opener
