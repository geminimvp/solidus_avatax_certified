# frozen_string_literal: true

module SolidusAvataxCertified
  module TestingSupport
    module Preferences
      def seed_avatax_preferences
        ::Spree::AvataxConfiguration.scoped(nil).tap do |config|
          config.company_code = '0' unless config.company_code.present?
          config.license_key = '12345' unless config.license_key.present?
          config.account = 'jdoe@example.com' unless config.account.present?

          config.refuse_checkout_address_validation_error = false
          config.log_to_stdout = false
          config.raise_exceptions = false
          config.log = true
          config.address_validation = true
          config.tax_calculation = true
          config.document_commit = true
          config.customer_can_validate = true

          config.address_validation_enabled_countries = ['United States', 'Canada']

          config.origin = "{\"line1\":\"915 S Jackson St\",\"line2\":\"\",\"city\":\"Montgomery\",\"region\":\"AL\",\"postalCode\":\"36104\",\"country\":\"US\"}"
        end
      end

      def stub_avatax_preference(pref_key, value)
        config = ::Spree::AvataxConfiguration.current || ::Spree::AvataxConfiguration.new

        allow(::SolidusAvataxCertified::Current).
          to receive(:config).
          and_return(config)

        allow(config).to receive(pref_key).and_return(value)
      end
    end
  end
end
