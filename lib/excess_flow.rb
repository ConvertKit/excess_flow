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

require 'securerandom'
require 'connection_pool'
require 'redis'

require 'excess_flow/constants'
require 'excess_flow/configuration'
require 'excess_flow/redis_connection'

require 'excess_flow/global_mutex'
require 'excess_flow/failed_execution'

require 'excess_flow/throttle_configuration'
require 'excess_flow/throttled_executor'
require 'excess_flow/configuration_error'

require 'excess_flow/strategy'
require 'excess_flow/fixed_window_strategy'
require 'excess_flow/sliding_window_strategy'
require 'excess_flow/rate_limited_execution_result'

# = ExcessFlow
#
# Precise rate limiter  with Redis as a backend. For more information on
# general usage consider consulting README.md file.
#
# While interacting with the rate limiter from within your application
# avoid re-using anything after :: notation as it is part of internal API
# and is subject to an un-announced breaking change.
#
# ExcessFlow provides 5 methods as part of it's public API:
# * configuration
# * configure
# * redis
# * redis_connection_pool
# * throttle
module ExcessFlow
  module_function

  # Provides access to cache's configuration.
  #
  # @return [Configuration] the object holding configuration values
  def configuration
    @configuration ||= Configuration.new
  end

  # API to configure cache dynamically during runtime.
  #
  # @yield [configuration] Takes in a block of code of code that is setting
  #   or changing configuration values
  #
  # @example Configure during runtime changing redis URL
  #   ExcessFlow.configure { |c| c.redis_url = 'foobar' }
  #
  # @return [void]
  def configure
    yield(configuration)
    nil
  end

  # API to communicate with Redis database backing cache up.
  #
  # @yield [redis]
  #
  # @example Store a value in Redis at given key
  #   Store.redis { |r| r.set('meaning_of_life', 42) }
  #
  # @return Returns a result of interaction with Redis
  def redis
    redis_connection_pool.with do |connection|
      yield connection
    end
  end

  # Accessor to connection pool. Defined on top level so it can be memoized
  # on the topmost level
  #
  # @return [ConnectionPool] ConnectionPool object from connection_pool gem
  def redis_connection_pool
    @redis_connection_pool ||= ExcessFlow::RedisConnection.connection_pool
  end

  # Executes passed in block of code rate limited using specified strategy
  # and arguments. Different call types can be differentiated and configured
  # using arguments.
  #
  # @param key [String] key to identify your request to limit. Requests that are
  #   identified by same key share limits
  # @param limit [Integer] number of requests that can be made in the specified
  #   time window
  # @param ttl [Integer] size of window in seconds; how long it will take until
  #   the limits are reset
  # @param strategy [Symbol] (optional) specifies which strategy to use to rate
  #   limit requests. Optional. Defaults to :fixed_window. Supported strategies
  #   are :fixed_window and :sliding_window.
  #
  # @return [ExcessFlow::RateLimitedExecutionResult] Execution result object that
  #   will hold result of your execution if it was under the limit. Accessible by
  #   calling `result` method. This object has two methods as part of it's public
  #   API: `result` (returns either result of execution or ExcessFlow::FailedExecution
  #   if limits were breached) and `success?` (returns `true` if request was within
  #   limits and else returns `false`).
  def throttle(args, &block)
    ExcessFlow::ThrottledExecutor.select_strategy_and_execute(args, &block)
  end
end
