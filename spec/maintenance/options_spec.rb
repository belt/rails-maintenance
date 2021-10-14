# frozen_string_literal: true

require 'spec_helper'

require 'maintenance/options'

# rubocop:disable Metrics/BlockLength
RSpec.describe Maintenance::Options do
  context 'when setting FEATURES' do
    before { ENV['FEATURES'] = 'foo,bar' }

    it 'casts as a CSV' do
      expect(Maintenance::Options::FEATURES).to be_a_kind_of(Enumerable)
    end
  end

  context 'when setting VERBOSE truthy' do
    it 'casts 1 and true as booleans', :aggregate_failures do
      allow(ENV).to receive(:[]).with('VERBOSE').and_return('true')
      expect(Maintenance::Options::VERBOSE).to be_truthy

      allow(ENV).to receive(:[]).with('VERBOSE').and_return('1')
      expect(Maintenance::Options::VERBOSE).to be_truthy
    end
  end

  context 'when setting VERBOSE falsey' do
    it 'casts true and false as booleans', :aggregate_failures do
      allow(ENV).to receive(:[]).with('VERBOSE').and_return('0')
      expect(Maintenance::Options::VERBOSE).to be_falsey

      allow(ENV).to receive(:[]).with('VERBOSE').and_return('false')
      expect(Maintenance::Options::VERBOSE).to be_falsey
    end
  end

  context 'when level-setting VERBOSE' do
    before do
      allow(ENV).to receive(:[]).with('VERBOSE').and_return('10')
    end

    it 'casts to an integer' do
      expect(Maintenance::Options::VERBOSE_LEVEL).to be_a_kind_of(Integer)
    end
  end

  context 'when scripting and needing a password from console' do
    it '.password_from_prompt' do
      expect(::Maintenance::Options).to respond_to(:password_from_prompt)
    end
  end
end
# rubocop:enable Metrics/BlockLength
