# frozen_string_literal: true

require 'spec_helper'

require 'maintenance/options'

# rubocop:disable Metrics/BlockLength
RSpec.describe Maintenance::Options do
  context 'when setting FEATURES' do
    # before { ENV['FEATURES'] = 'foo,bar' }

    it 'casts as a CSV' do
      ClimateControl.modify FEATURES: 'foo,bar' do
        expect(Maintenance::Options.config.features).to be_a_kind_of(Enumerable)
      end
    end
  end

  context 'when setting VERBOSE truthy', skip: 'VERBOSE is always nil' do
    # hypothesis: eager loading of class as class constant
    ClimateControl.modify VERBOSE: 'TRUE' do
      it 'casts TRUE as boolean', :aggregate_failures do
        expect(Maintenance::Options.config.verbose).to be_truthy
      end
    end

    ClimateControl.modify VERBOSE: 'true' do
      it 'casts true as boolean', :aggregate_failures do
        expect(Maintenance::Options.config.verbose).to be_truthy
      end
    end

    ClimateControl.modify VERBOSE: '1' do
      it 'casts 1 as boolean', :aggregate_failures do
        expect(Maintenance::Options.config.verbose).to be_truthy
      end
    end
  end

  context 'when setting VERBOSE falsey' do
    ClimateControl.modify VERBOSE: 'FALSE' do
      it 'casts false as boolean', :aggregate_failures do
        expect(Maintenance::Options.config.verbose).to be_falsey
      end
    end

    ClimateControl.modify VERBOSE: 'false' do
      it 'casts false as boolean', :aggregate_failures do
        expect(Maintenance::Options.config.verbose).to be_falsey
      end
    end

    ClimateControl.modify VERBOSE: '0' do
      it 'casts 0 as boolean', :aggregate_failures do
        expect(Maintenance::Options.config.verbose).to be_falsey
      end
    end
  end

  context 'when level-setting VERBOSE' do
    it 'casts to an integer' do
      ClimateControl.modify VERBOSE: '10' do
        expect(Maintenance::Options.config.verbose_level).to be_a_kind_of(Integer)
      end
    end
  end

  context 'when scripting and needing a password from console' do
    it '.password_from_prompt' do
      expect(::Maintenance::Options).to respond_to(:password_from_prompt)
    end
  end
end
# rubocop:enable Metrics/BlockLength
