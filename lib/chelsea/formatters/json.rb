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

require 'json'
require_relative 'formatter'

module Chelsea
  class JsonFormatter < Formatter
    def initialize(options)
      @options = options
    end

    def get_results(server_response, reverse_deps)
      server_response.to_json
    end

    def do_print(result)
      puts result
    end
  end
end
