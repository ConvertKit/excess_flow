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
  CONFIGURATION_ERROR_MESSAGE = 'Invalid arguments provided. Please refer to README.md'
  COUNTER_PREFIX = 'excess_flow::counter::'
  DEFAULT_CONNECTION_POOL = 100
  DEFAULT_CONNECTION_TIMEOUT = 3
  DEFAULT_REDIS_URL = 'redis://localhost:6379/1'
  LOCK_PREFIX = 'excess_flow::lock::'
  MUTEX_LOCK_TIME = 1
  MUTEX_SLEEP_TIME = 1 / 100_000
  VERSION = '1.0.1'
end
