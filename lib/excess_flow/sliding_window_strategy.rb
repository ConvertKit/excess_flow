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
  # == ExcessFlow::SlidingWindowStrategy
  #
  # Definition of sliging window rate limiting strategy and it's behaviour
  # implementations. Sliding window allows only N requests for a given key to
  # be done in a trailing O time window where O start is defined as `now` -
  # `window_size`. Window expiration starts with the first request for a given
  # key. Once expired it will reset back to 0.
  class SlidingWindowStrategy < ExcessFlow::Strategy
    def within_rate_limit?
      ExcessFlow::GlobalMutex.locked(lock_key: configuration.lock_key) do
        cleanup_stale_counters

        if current_requests < configuration.limit
          bump_counter
          start_expiration_window

          true
        else
          false
        end
      end
    end

    private

    def bump_counter
      ExcessFlow.redis do |r|
        r.zadd(
          configuration.counter_key,
          current_timestamp,
          SecureRandom.uuid
        )
      end
    end

    def cleanup_stale_counters
      ExcessFlow.redis do |r|
        r.zremrangebyscore(configuration.counter_key, 0, "(#{window_start}")
      end
    end

    def current_requests
      @current_requests ||= ExcessFlow.redis { |r| r.zcount(configuration.counter_key, '-inf', '+inf') }
    end

    def current_timestamp
      @current_timestamp ||= (Time.now.to_f * 100_000).to_i
    end

    def start_expiration_window
      return if current_requests.zero?

      ExcessFlow.redis { |r| r.expire(configuration.counter_key, configuration.ttl) }
    end

    def window_start
      @window_start ||= current_timestamp - (configuration.ttl * 100_000)
    end
  end
end
