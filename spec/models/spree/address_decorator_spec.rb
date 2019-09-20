# frozen_string_literal: true

require 'spec_helper'

describe Spree::Address, type: :model do
  let(:address) { build(:address) }

  describe '#validation_enabled?' do
    context 'when validation is true and country validation is enabled' do
      before do
        stub_avatax_preference(:address_validation, true)
        stub_avatax_preference(:address_validation_enabled_countries, ['United States', 'Canada'])
      end

      it 'returns true if preference is true and country validation is enabled' do
        expect(address).to be_validation_enabled
      end
    end

    context 'when address validation is false' do
      before do
        stub_avatax_preference(:address_validation, false)
      end

      it 'returns false if address validation preference is false' do
        expect(address).not_to be_validation_enabled
      end
    end


    context 'when enabled country is not present' do
      before do
        stub_avatax_preference(:address_validation_enabled_countries, ['Canada'])
      end

      it 'returns false if enabled country is not present' do
        expect(address).not_to be_validation_enabled
      end
    end

    context 'when no avatax config is present' do
      before do
        allow(::SolidusAvataxCertified::Current).to receive(:config) { nil }
      end

      it 'returns false' do
        expect(address).to_not be_validation_enabled
      end
    end
  end

  describe '#country_validation_enabled?' do
    it 'returns true if the current country is enabled' do
      expect(address).to be_country_validation_enabled
    end

    context 'when no avatax config is present' do
      before do
        allow(::SolidusAvataxCertified::Current).to receive(:config) { nil }
      end

      it 'returns false' do
        expect(address).to_not be_country_validation_enabled
      end
    end
  end

  describe '#validation_enabled_countries' do
    it 'returns an array' do
      expect(Spree::Address.validation_enabled_countries).to be_kind_of(Array)
    end

    it 'includes United States' do
      stub_avatax_preference(:address_validation_enabled_countries, ['United States', 'Canada'])

      expect(Spree::Address.validation_enabled_countries).to include('United States')
    end
  end
end
