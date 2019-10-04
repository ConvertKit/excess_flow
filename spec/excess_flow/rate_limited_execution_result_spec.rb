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

RSpec.describe ExcessFlow::RateLimitedExecutionResult do
  describe '#success?' do
    it 'returns true unless result is a FailedLock' do
      result = ExcessFlow::RateLimitedExecutionResult.new('')

      expect(result.success?).to eq(true)
    end

    it 'returns false if result is a FailedLock' do
      failed = ExcessFlow::FailedExecution.new
      result = ExcessFlow::RateLimitedExecutionResult.new(failed)

      expect(result.success?).to eq(false)
    end

    it 'has an accessor for a result passed in' do
      result = ExcessFlow::RateLimitedExecutionResult.new('foo')

      expect(result.result).to eq('foo')
    end
  end
end
