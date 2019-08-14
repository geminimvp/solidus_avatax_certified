# frozen_string_literal: true

module SolidusAvataxCertified
  module Spree
    module CheckoutControllerDecorator
      def validate_address
        address = permitted_address_validation_attrs

        address['country'] = ::Spree::Country.find_by(id: address['country']).try(:iso)
        address['region'] = ::Spree::State.find_by(id: address['region']).try(:abbr)

        response = avatax_service.validate_address(address)
        result = response.result

        if response.failed?
          result['responseCode'] = 'error'
          result['errorMessages'] = response.summary_messages
        end

        respond_to do |format|
          format.json { render json: result }
        end
      end

      private

      def avatax_service
        TaxSvc.new
      end

      def permitted_address_validation_attrs
        params['address'].permit(:line1, :line2, :city, :postalCode, :country, :region).to_h
      end

      ::Spree::CheckoutController.prepend self
    end
  end
end
