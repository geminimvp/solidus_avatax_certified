# frozen_string_literal: true

module SolidusAvataxCertified
  class PreferenceUpdater
    attr_accessor :avatax_config

    def initialize(params)
      @avatax_origin = params[:address] || {}
      @avatax_preferences = params[:settings]
      @avatax_config = SolidusAvataxCertified::Current.config
    end

    def update
      update_storable_settings
      update_boolean_settings
      update_validation_enabled_countries
      update_origin_address
    end

    private

    def update_boolean_settings
      ::Spree::AvataxConfiguration.boolean_preferences.each do |key|
        avatax_config[key.to_sym] = @avatax_preferences[key] || false
      end
    end

    def update_storable_settings
      ::Spree::AvataxConfiguration.storable_env_preferences.each do |key|
        avatax_config[key.to_sym] = @avatax_preferences[key] || ENV["AVATAX_#{key.upcase}"]
      end
    end

    def update_origin_address
      set_region
      set_country
      avatax_config.origin = @avatax_origin.to_json
    end

    def update_validation_enabled_countries
      if @avatax_preferences['address_validation_enabled_countries'].present?
        avatax_config.address_validation_enabled_countries = @avatax_preferences['address_validation_enabled_countries']
      end
    end

    def set_region
      region = @avatax_origin['region']
      unless region.blank?
        @avatax_origin['region'] = ::Spree::State.find(region).try(:abbr)
      end
    end

    def set_country
      country = @avatax_origin['country']
      unless country.blank?
        @avatax_origin['country'] = ::Spree::Country.find(country).try(:iso)
      end
    end
  end
end
