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
  # == ExcessFlow::Strategy
  #
  # Base class for implementing different strategies for rate limiting.
  class Strategy
    attr_reader :configuration

    def self.execute(configuration:, &block)
      new(configuration).execute(&block)
    end

    def initialize(configuration)
      @configuration = configuration
    end

    def execute
      result = if within_rate_limit?
                 yield
               else
                 FailedExecution.new
               end

      RateLimitedExecutionResult.new(result)
    end

    def within_rate_limit?
      true
    end
  end
end
