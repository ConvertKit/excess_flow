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

RSpec.describe ExcessFlow do
  describe '#configuration' do
    it 'returns configuration object' do
      expect(ExcessFlow.configuration).to be_kind_of(ExcessFlow::Configuration)
    end
  end

  describe '#configure' do
    it 'allows to create custom configuration' do
      ExcessFlow.configure do |c|
        expect(c).to respond_to(:connection_pool=)
        expect(c).to respond_to(:connection_timeout=)
        expect(c).to respond_to(:redis_url=)
        expect(c).to respond_to(:sentinels=)
      end
    end
  end

  describe '#redis' do
    it 'yields control' do
      expect { |b| ExcessFlow.redis(&b) }.to yield_control
    end
  end

  describe '#redis_connection_pool' do
    it 'returns a ConnectionPool object' do
      pool = ExcessFlow.redis_connection_pool

      expect(pool).to be_a(ConnectionPool)
    end
  end

  describe '#throttle' do
    it 'relays call to ThrottledExecutor' do
      allow(ExcessFlow::ThrottledExecutor).to receive(:select_strategy_and_execute)
      expected_params = { key: 'foo', ttl: 1 }
      ExcessFlow.throttle(key: 'foo', ttl: 1)

      expect(ExcessFlow::ThrottledExecutor).to have_received(:select_strategy_and_execute).with(expected_params)
    end
  end
end
