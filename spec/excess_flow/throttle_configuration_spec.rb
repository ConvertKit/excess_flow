# frozen_string_literal: true

# Copyright 2019 ConvertKit, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

RSpec.describe ExcessFlow::ThrottleConfiguration do
  let(:configuration_attributes) { { key: 'foo', limit: 1, ttl: 1, strategy: :foo } }
  let(:configuration) { ExcessFlow::ThrottleConfiguration.new(configuration_attributes) }

  describe '.initialize' do
    it 'builds a configuration object with passed in args set as instance variables' do
      expect(configuration.instance_variable_get(:@key)).to eq('foo')
      expect(configuration.instance_variable_get(:@limit)).to eq(1)
      expect(configuration.instance_variable_get(:@ttl)).to eq(1)
      expect(configuration.instance_variable_get(:@strategy)).to eq(:foo)
    end

    it 'will raise if disallowed key is provided' do
      expect do
        ExcessFlow::ThrottleConfiguration.new(foo: 'bar')
      end.to raise_error(ExcessFlow::ConfigurationError)
    end

    it 'will raise if one of the mandatory keys is not provided' do
      expect do
        ExcessFlow::ThrottleConfiguration.new(key: 'foo', limit: 1)
      end.to raise_error(ExcessFlow::ConfigurationError)
    end
  end

  describe '#counter_key' do
    it 'returns provided key prefixed by COUNTER_PREFIX' do
      expected_key = ExcessFlow::COUNTER_PREFIX + 'foo'

      expect(configuration.counter_key).to eq(expected_key)
    end
  end

  describe '#lock_key' do
    it 'returns lock key prefixed with LOCK_PREFIX' do
      expected_key = ExcessFlow::LOCK_PREFIX + 'foo'

      expect(configuration.lock_key).to eq(expected_key)
    end
  end

  describe '#strategy' do
    it 'returns ExcessFlow::FixedWindowStrategy when :fixed_window is provided' do
      attributes = configuration_attributes.merge(strategy: :fixed_window)
      configuration = ExcessFlow::ThrottleConfiguration.new(attributes)

      expect(configuration.strategy).to eq(ExcessFlow::FixedWindowStrategy)
    end

    it 'returns ExcessFlow::FixedWindowStrategy when no strategy is provided' do
      configuration = ExcessFlow::ThrottleConfiguration.new(configuration_attributes)

      expect(configuration.strategy).to eq(ExcessFlow::FixedWindowStrategy)
    end
  end
end
