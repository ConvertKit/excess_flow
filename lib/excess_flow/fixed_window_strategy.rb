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
  # == ExcessFlow::FixedWindowStrategy
  #
  # Definition of fixed window rate limiting strategy and it's behaviour
  # implementations. Fixed window allows only N requests for a given key to be
  # done in a O time window where O start is defined at the time of first
  # request. Window expiration starts with the first request for a given key.
  # Once expired it will reset back to 0.
  class FixedWindowStrategy < ExcessFlow::Strategy
    def within_rate_limit?
      ExcessFlow::GlobalMutex.locked(lock_key: configuration.lock_key) do
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
      ExcessFlow.redis { |r| r.incr(configuration.counter_key) }
    end

    def current_requests
      @current_requests ||= ExcessFlow.redis { |r| r.get(configuration.counter_key) }.to_i
    end

    def start_expiration_window
      return unless current_requests.zero?

      ExcessFlow.redis { |r| r.expire(configuration.counter_key, configuration.ttl) }
    end
  end
end
