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
  # == ExcessFlow::GlobalMutex
  #
  # Attempts to set up exclusive lock to execute a block of code. If another
  # lock is in place then GlobalMutex will wait till lock is available. Always
  # returns result of execution. GlobalMutex does not guarantee order of execution;
  # it will only guarantee that only one thread for a given lock_key is running to
  # avoid race conditions.
  class GlobalMutex
    attr_reader :lock_key

    def self.locked(lock_key:, &block)
      new(lock_key).locked(&block)
    end

    def initialize(lock_key)
      @lock_key = lock_key
    end

    def locked(&block)
      sleep(ExcessFlow::MUTEX_SLEEP_TIME) until lock
      result = block.call
      unlock

      result
    end

    private

    def lock
      ExcessFlow.redis { |r| r.set(lock_key, 1, nx: true, ex: ExcessFlow::MUTEX_LOCK_TIME) }
    end

    def unlock
      ExcessFlow.redis { |r| r.expire(lock_key, 0) }
    end
  end
end
