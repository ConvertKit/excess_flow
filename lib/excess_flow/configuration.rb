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
  # == ExcessFlow::Configuration
  #
  # Holds configuration for rate limiter with writeable attributes allowing
  # dynamic change of configuration during runtime
  class Configuration
    attr_accessor(
      :connection_pool,
      :connection_timeout,
      :redis_url,
      :sentinels
    )

    def initialize
      @connection_pool = extract_connection_pool
      @connection_timeout = extract_connection_timeout
      @redis_url = extract_redis_url
      @sentinels = process_sentinels
    end

    private

    def extract_connection_pool
      ENV.fetch(
        'EXCESS_FLOW_CONNECTION_POOL',
        ExcessFlow::DEFAULT_CONNECTION_POOL
      ).to_i
    end

    def extract_connection_timeout
      ENV.fetch(
        'EXCESS_FLOW_CONNECTION_TIMEOUT',
        ExcessFlow::DEFAULT_CONNECTION_TIMEOUT
      ).to_i
    end

    def extract_redis_url
      ENV.fetch(
        'EXCESS_FLOW_REDIS_URL',
        ExcessFlow::DEFAULT_REDIS_URL
      )
    end

    def process_sentinels
      ENV.fetch('EXCESS_FLOW_REDIS_SENTINELS', '').split(',').map do |sentinel|
        host, port = sentinel.split(':')
        { host: host, port: port.to_i }
      end
    end
  end
end
