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

require 'ostruct'

RSpec.describe ExcessFlow::SlidingWindowStrategy do
  after(:each) do
    ExcessFlow.redis { |r| r.expire('foo', 0) }
    ExcessFlow.redis { |r| r.expire('bar', 0) }
  end

  let(:configuration) { OpenStruct.new(counter_key: 'foo', lock_key: 'bar', ttl: 1, limit: 1) }

  describe '#within_rate_limit?' do
    it 'returns true if execution is under the limit' do
      strategy = ExcessFlow::FixedWindowStrategy.new(configuration)

      expect(strategy.within_rate_limit?).to eq(true)
    end

    it 'returns false if execution is over the limit' do
      result = 2.times.map do
        ExcessFlow::FixedWindowStrategy.new(configuration).within_rate_limit?
      end

      expect(result[0]).to eq(true)
      expect(result[1]).to eq(false)
    end

    it 'epires stale pointers in sorted set' do
      ExcessFlow.redis { |r| r.zadd('foo', 1, 1) }

      expect(ExcessFlow.redis { |r| r.zrange('foo', 0, -1) }).to eq(['1'])

      ExcessFlow::SlidingWindowStrategy.new(configuration).within_rate_limit?

      expect(ExcessFlow.redis { |r| r.zrange('foo', 0, -1) }).not_to include(['1'])
    end

    it 'drops in current timestamp into pointers sorted set (with 1/100_000 precision)' do
      allow(Time).to receive(:now).and_return(42)

      ExcessFlow::SlidingWindowStrategy.new(configuration).within_rate_limit?

      expect(ExcessFlow.redis { |r| r.zrange('foo', 0, -1) }).to eq(['4200000'])
    end
  end
end
