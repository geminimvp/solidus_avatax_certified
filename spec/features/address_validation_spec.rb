# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Address Validation Button in Checkout', :vcr, :js do
  let(:address) { create(:address) }
  let!(:order) { create(:order_with_line_items, state: 'address', ship_address: address) }
  let!(:user) { order.user }
  let(:address_field) do
    if order.shipping_eq_billing_address?
      'order_bill_address_attributes'
    else
      'order_ship_address_attributes'
    end
  end

  # With button enabled
  # with refuse checkout on failure

  context 'Customer validate button enabled' do
    let(:customer_can_validate) { true }

    before { prep_page }

    context 'success' do
      it 'validates successfully and populates with validated address' do
        expect(page).to have_content('Validate Ship Address')

        expect(find("##{address_field}_zipcode").value).to eq('36104')
        click_button 'Validate Ship Address'
        wait_for_ajax
        expect(find('.address_validator')).to have_content('Address Validation Successful')
        expect(find("##{address_field}_zipcode").value).to eq('36104-5716')
      end
    end

    context 'error' do
      let(:address) { create(:address, zipcode: '36104', address1: '5 t') }

      it 'validation fails and flashes error' do
        expect(page).to have_content('Validate Ship Address')
        expect(find("##{address_field}_zipcode").value).to eq('36104')
        click_button 'Validate Ship Address'
        wait_for_ajax
        flash = find('.flash.error')

        expect(flash).to be_present
        expect(flash).to have_content('Address Validation Error: The address number is out of range')
        expect(find("##{address_field}_zipcode").value).to eq('36104')
      end
    end
  end

  context 'Customer validate button disabled' do
    let(:customer_can_validate) { false }

    it 'does not have validate button on address page' do
      prep_page
      expect(page).not_to have_content('Validate Ship Address')
    end
  end

  def prep_page
    stub_avatax_preference(:customer_can_validate, customer_can_validate)

    allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
    allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
    visit spree.checkout_state_path(:address)
  end
end
