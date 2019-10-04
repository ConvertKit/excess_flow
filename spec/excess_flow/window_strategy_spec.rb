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
  class StrategySpecKlass
    def self.perform; end
  end

  describe '.execute' do
    it 'is a shortcut for constructor with method call' do
      strategy = ExcessFlow::Strategy.new('foo')
      allow(ExcessFlow::Strategy).to receive(:new).and_return(strategy)
      allow(strategy).to receive(:execute)
      ExcessFlow::Strategy.execute(configuration: 'foo') {}

      expect(strategy).to have_received(:execute)
    end
  end

  describe '#execute' do
    it 'returns RateLimitedExecutionResult' do
      result = ExcessFlow::Strategy.new('foo').execute {}

      expect(result).to be_a(ExcessFlow::RateLimitedExecutionResult)
    end

    it 'will call passed in block of code if request is within rate limit' do
      allow(StrategySpecKlass).to receive(:perform)
      ExcessFlow::Strategy.new('foo').execute { StrategySpecKlass.perform }

      expect(StrategySpecKlass).to have_received(:perform)
    end

    it 'will not call block of code if request is outside of limit' do
      strategy = ExcessFlow::Strategy.new('foo')
      allow(StrategySpecKlass).to receive(:perform)
      allow(strategy).to receive(:within_rate_limit?).and_return(false)

      strategy.execute { StrategySpecKlass.perform }

      expect(StrategySpecKlass).not_to have_received(:perform)
    end
  end

  describe '#within_rate_limit?' do
    it 'always returns true' do
      strategy = ExcessFlow::Strategy.new('foo')

      expect(strategy.within_rate_limit?).to eq(true)
    end
  end
end
