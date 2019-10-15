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

RSpec.describe ExcessFlow::FixedWindowStrategy do
  after(:each) do
    ExcessFlow.redis { |r| r.expire('foo', 0) }
    ExcessFlow.redis { |r| r.expire('bar', 0) }
  end

  let(:configuration) { OpenStruct.new(counter_key: 'foo', lock_key: 'bar', ttl: 10, limit: 2) }

  describe '#within_rate_limit?' do
    it 'returns true if executuion is under the limit' do
      strategy = ExcessFlow::FixedWindowStrategy.new(configuration)

      expect(strategy.within_rate_limit?).to eq(true)
    end

    it 'returns false if execution if over the limit' do
      result = 3.times.map do
        ExcessFlow::FixedWindowStrategy.new(configuration).within_rate_limit?
      end

      succesful_execution_results = result[0..1]

      expect(succesful_execution_results).to eq([true, true])
      expect(result[-1]).to eq(false)
    end

    it 'sets window expiration on the first request' do
      ExcessFlow::FixedWindowStrategy.new(configuration).within_rate_limit?

      expect(ExcessFlow.redis { |r| r.ttl('foo') }).to be_between(1, 10)
    end
  end
end
