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
  # == ExcessFlow::ThrottleConfiguration
  #
  # Wrapper class for throttle execution result that does provide some basic
  # transformation of provided values.
  class ThrottleConfiguration
    MANDATORY_KEYS = %i[
      key
      limit
      ttl
    ].freeze

    OPTIONAL_KEYS = %i[
      strategy
    ].freeze

    attr_reader :key, :limit, :ttl

    def initialize(args)
      @raw_args = args
      validate_args

      args.each do |key, value|
        instance_variable_set("@#{key}", value) unless value.nil?
      end
    end

    def counter_key
      ExcessFlow::COUNTER_PREFIX + key
    end

    def lock_key
      ExcessFlow::LOCK_PREFIX + key
    end

    def strategy
      case @strategy
      when :fixed_window then ExcessFlow::FixedWindowStrategy
      when :sliding_window then ExcessFlow::SlidingWindowStrategy
      else ExcessFlow::FixedWindowStrategy
      end
    end

    private

    def allowed_keys_passed_in?
      (@raw_args.keys - (MANDATORY_KEYS + OPTIONAL_KEYS)).empty?
    end

    def mandatory_keys_are_present?
      (MANDATORY_KEYS - @raw_args.keys).empty?
    end

    def validate_args
      return if allowed_keys_passed_in? && mandatory_keys_are_present?

      raise ExcessFlow::ConfigurationError, CONFIGURATION_ERROR_MESSAGE
    end
  end
end
