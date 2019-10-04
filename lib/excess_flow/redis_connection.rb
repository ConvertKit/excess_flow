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
  # == ExcessFlow::RedisConnection
  #
  # Wrapper around ConnectionPool and Redis to provide connectivity
  # to Redis with desired configuration and sane connection pool
  module RedisConnection
    module_function

    def connection_pool
      @connection_pool = ConnectionPool.new(connection_pool_options) do
        Redis.new(connection_options)
      end
    end

    def connection_options
      {
        url: redis_url,
        sentinels: sentinels
      }.delete_if { |_k, v| v.nil? || v.empty? }
    end

    def connection_pool_options
      {
        size: pool_size,
        timeout: connection_timeout
      }
    end

    def connection_timeout
      ExcessFlow.configuration.connection_timeout
    end

    def pool_size
      ExcessFlow.configuration.connection_pool
    end

    def redis_url
      ExcessFlow.configuration.redis_url
    end

    def sentinels
      ExcessFlow.configuration.sentinels
    end
  end
end
