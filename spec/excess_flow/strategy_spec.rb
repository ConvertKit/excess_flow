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

RSpec.describe ExcessFlow::Strategy do
  describe '.execute' do
    it 'is a shortcut for constructor with method call' do
      strategy = ExcessFlow::Strategy.new(configuration: 'foo')
      allow(ExcessFlow::Strategy).to receive(:new).and_return(strategy)
      allow(strategy).to receive(:execute)
      ExcessFlow::Strategy.execute(configuration: 'foo') {}

      expect(strategy).to have_received(:execute)
    end
  end

  describe '#execute' do
    it 'always returns RateLimitedExecutionResult' do
      result = ExcessFlow::Strategy.execute(configuration: '') {}

      expect(result).to be_a(ExcessFlow::RateLimitedExecutionResult)
    end

    it 'yields and returns result of a block if is within rate limit' do
      result = ExcessFlow::Strategy.execute(configuration: '') { 'bar' }

      expect(result.result).to eq('bar')
    end

    it 'returns FailedExecution as a result if outside of rate limit' do
      strategy = ExcessFlow::Strategy.new('')
      allow(strategy).to receive(:within_rate_limit?).and_return(false)
      result = strategy.execute { 'bar' }

      expect(result.result).to be_a(ExcessFlow::FailedExecution)
    end
  end

  describe '#within_rate_limit?' do
    it 'always returns true' do
      expect(ExcessFlow::Strategy.new(configuration: 'foo').within_rate_limit?).to eq(true)
    end
  end
end
