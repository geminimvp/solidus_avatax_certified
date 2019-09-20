# frozen_string_literal: true

require 'spec_helper'

describe SolidusAvataxCertified::AvataxLog, type: :model do
  let(:logger) { SolidusAvataxCertified::AvataxLog.new('test_file.rb', 'test info') }
  let(:request_hash) { attributes_for(:request_hash) }

  before do
    stub_avatax_preference(:log_to_stdout, false)
  end

  describe '#enabled?' do
    context 'when logging is enabled' do
      before do
        stub_avatax_preference(:log, true)
      end

      it 'returns true' do
        expect(logger).to be_enabled
      end
    end

    context 'when no config is present' do
      before do
        allow(::SolidusAvataxCertified::Current).to receive(:config) { nil }
      end

      it 'returns false' do
        expect(logger).to_not be_enabled
      end
    end
  end

  describe '#progname' do
    it 'sets the logger progname' do
      stub_avatax_preference(:log_to_stdout, false)
      stub_avatax_preference(:log, true)

      expect{ logger.progname('changed') }.to change(logger, :progname).from('test_file').to('changed')
    end

    it 'returns nil if logger is not enabled' do
      stub_avatax_preference(:log, false)

      expect(logger.progname('this_wont_change')).to be_nil
    end
  end

  describe '#info' do
    it 'logs info with given message' do
      expect(logger.logger).to receive(:info).with('[AVATAX] Hyah! ')
      logger.info('Hyah!')
    end

    it 'returns nil if logger is not enabled' do
      stub_avatax_preference(:log, false)

      expect(logger.info('this_wont_change')).to be_nil
    end
  end

  describe '#info_and_debug' do
    it 'recieves info and debug messages' do
      expect(logger.logger).to receive(:info).with('[AVATAX] Hyah!')
      expect(logger.logger).to receive(:debug).with("[AVATAX] [\"Heuh!\"]")

      logger.info_and_debug('Hyah!', ['Heuh!'])
    end

    it 'returns nil if logger is not enabled' do
      stub_avatax_preference(:log, false)

      expect(logger.info_and_debug('Hyah!', ['Heuh!'])).to be_nil
    end
  end

  describe '#debug' do
    it 'receives debug with message' do
      expect(logger.logger).to receive(:debug).with("[AVATAX] Heuh #{request_hash}")

      logger.debug(request_hash, 'Heuh')
    end

    it 'returns nil if logger is not enabled' do
      stub_avatax_preference(:log, false)

      expect(logger.debug(['Heuh!'])).to be_nil
    end
  end

  describe '#error' do
    it 'logs error with given message' do
      expect(logger.logger).to receive(:error).with("[AVATAX] Hyah! #{request_hash}")
      logger.error(request_hash, 'Hyah!')
    end

    it 'returns nil if logger is not enabled' do
      stub_avatax_preference(:log, false)

      expect(logger.error('this_wont_change')).to be_nil
    end
  end
end
