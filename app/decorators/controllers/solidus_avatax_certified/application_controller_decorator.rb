# frozen_string_literal: true

module SolidusAvataxCertified
  module ApplicationControllerDecorator
    def self.prepended(base)
      base.helper_method :current_avatax_config
    end

    def current_avatax_config
      ::Spree::AvataxConfiguration.current
    end

    ::ApplicationController.prepend(self)
  end
end
