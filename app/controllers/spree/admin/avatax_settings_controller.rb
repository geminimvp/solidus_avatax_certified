# frozen_string_literal: true

module Spree
  module Admin
    class AvataxSettingsController < Spree::Admin::BaseController
      before_action :load_avatax_origin, only: %i[show edit]

      def show; end

      def download_avatax_log
        send_file "#{Rails.root}/log/avatax.log"
      end

      def erase_data
        File.open("log/avatax.log", 'w') {}

        head :ok
      end

      def ping_my_service
        response = avatax_service.ping

        if response.success?
          flash[:success] = 'Ping Successful'
        else
          flash[:error] = 'Ping Error'
        end

        respond_to do |format|
          format.html { render layout: !request.xhr? }
          format.js { render layout: false }
        end
      end

      def validate_address
        address = permitted_address_validation_attrs

        address['country'] = Spree::Country.find_by(id: address['country']).try(:iso)
        address['region'] = Spree::State.find_by(id: address['region']).try(:abbr)

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

      def update
        updater = SolidusAvataxCertified::PreferenceUpdater.new(params)
        if updater.update
          redirect_to admin_avatax_settings_path
        else
          flash[:error] = 'There was an error updating your Avalara Preferences'
          redirect_to :back
        end
      end

      private

      def avatax_service
        TaxSvc.new
      end

      def load_avatax_origin
        current_origin = current_avatax_config.origin
        @avatax_origin = if current_origin.blank?
                           {}
                         else
                           JSON.parse(current_origin)
                         end
      end

      def permitted_address_validation_attrs
        params['address'].permit(:line1, :line2, :city, :postalCode, :country, :region).to_h
      end
    end
  end
end
