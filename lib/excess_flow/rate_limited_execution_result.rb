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

module ExcessFlow
  # == ExcessFlow::RateLimitedExecutionResult
  #
  # Wrapper containing result of rate limited execution
  class RateLimitedExecutionResult
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def success?
      !result.is_a?(FailedExecution)
    end
  end
end
