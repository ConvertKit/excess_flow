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
  # == ExcessFlow::ThrottledExecutor
  #
  # Wrapper service class that will take care of initialization of configuration
  # object and will execute on correct throttling strategy.
  class ThrottledExecutor
    attr_reader :args

    def self.select_strategy_and_execute(args, &block)
      new(args).select_strategy_and_execute(&block)
    end

    def initialize(args)
      @args = args
    end

    def select_strategy_and_execute(&block)
      strategy.execute(configuration: configuration, &block)
    end

    private

    def configuration
      @configuration ||= ExcessFlow::ThrottleConfiguration.new(args)
    end

    def strategy
      configuration.strategy
    end
  end
end
