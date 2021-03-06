#
# Copyright 2019-Present Sonatype Inc.
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
#

require 'pstore'

module Chelsea
  class DB
    def initialize
      @store = PStore.new(_get_db_store_location)
    end

    # This method will take an array of values, and save them to a pstore database
    # and as well set a TTL of Time.now to be checked later
    def save_values_to_db(values)
      values.each do |val|
        next unless get_cached_value_from_db(val['coordinates']).nil?

        new_val = val.dup
        new_val['ttl'] = Time.now
        @store.transaction do
          @store[new_val['coordinates']] = new_val
        end
      end
    end

    # This method will delete all values in the pstore db
    def clear_cache
      @store.transaction do
        @store.roots.each do |root|
          @store.delete(root)
        end
      end
    end

    def _get_db_store_location()
      initial_path = File.join(Dir.home.to_s, '.ossindex')
      Dir.mkdir(initial_path) unless File.exist? initial_path
      File.join(initial_path, 'chelsea.pstore')
    end

    # Checks pstore to see if a coordinate exists, and if it does also
    # checks to see if it's ttl has expired. Returns nil unless a record
    # is valid in the cache (ttl has not expired) and found
    def get_cached_value_from_db(val)
      record = @store.transaction { @store[val] }
      return if record.nil?

      (Time.now - record['ttl']) / 3600 > 12 ? nil : record
    end
  end
end
