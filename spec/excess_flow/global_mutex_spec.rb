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

RSpec.describe ExcessFlow::GlobalMutex do
  after(:each) do
    ExcessFlow.redis { |r| r.expire('foo', 0) }
  end

  describe '.locked' do
    it 'is a shortcut for constructor with method call' do
      mutex = ExcessFlow::GlobalMutex.new('foo')
      allow(ExcessFlow::GlobalMutex).to receive(:new).and_return(mutex)
      allow(mutex).to receive(:locked)
      ExcessFlow::GlobalMutex.locked(lock_key: 'foo') {}

      expect(mutex).to have_received(:locked)
    end
  end

  describe '#locked' do
    it 'returns execution result' do
      execution = ExcessFlow::GlobalMutex.locked(lock_key: 'foo') { 'bar' }

      expect(execution).to eq('bar')
    end

    it 'properly sets lock not allow concurent execution' do
      another_result = nil

      result = ExcessFlow::GlobalMutex.locked(lock_key: 'foo') do
        another_result = Thread.new do
          ExcessFlow::GlobalMutex.locked(lock_key: 'foo') { 'baz' }
        end

        expect(another_result).not_to eq('baz')

        'bar'
      end

      another_result.join

      expect(result).to eq('bar')
      expect(another_result.value).to eq('baz')
    end

    it 'will set lock that degrades over time' do
      ExcessFlow::GlobalMutex.locked(lock_key: 'foo') do
        lock_key_ttl = ExcessFlow.redis { |r| r.ttl('foo') }
        expect(lock_key_ttl).to be_between(1, 2)
      end
    end
  end
end
