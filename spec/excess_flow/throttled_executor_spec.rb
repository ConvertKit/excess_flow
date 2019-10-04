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

RSpec.describe ExcessFlow::GlobalMutex do
  let(:configuration_attributes) { { key: 'foo', limit: 1, ttl: 1, strategy: :foo } }
  let(:executor) { ExcessFlow::ThrottledExecutor.new(configuration_attributes) }

  class NilStrategy
    def execute(_); end
  end

  describe '.select_strategy_and_execute' do
    it 'is a shortcut for constructor with method call' do
      executor = ExcessFlow::ThrottledExecutor.new('foo')
      allow(ExcessFlow::ThrottledExecutor).to receive(:new).and_return(executor)
      allow(executor).to receive(:select_strategy_and_execute)
      ExcessFlow::ThrottledExecutor.select_strategy_and_execute(configuration_attributes) {}

      expect(executor).to have_received(:select_strategy_and_execute)
    end
  end

  describe '#select_strategy_and_execute' do
    it 'creates configuration object with passed in arguments' do
      allow(ExcessFlow::ThrottleConfiguration).to receive(:new)
      allow(executor).to receive(:strategy).and_return(NilStrategy.new)

      executor.select_strategy_and_execute {}

      expect(ExcessFlow::ThrottleConfiguration).to have_received(:new).with(configuration_attributes)
    end

    it 'invokes execution on strategy object' do
      strategy = NilStrategy.new
      allow(executor).to receive(:strategy).and_return(strategy)
      allow(strategy).to receive(:execute)

      executor.select_strategy_and_execute {}

      expect(strategy).to have_received(:execute)
    end
  end
end
