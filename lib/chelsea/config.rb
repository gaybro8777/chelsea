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

require 'yaml'
require_relative 'oss_index'

module Chelsea
  @oss_index_config_location = File.join(Dir.home.to_s, '.ossindex')
  @oss_index_config_filename = '.oss-index-config'

  def self.to_purl(name, version)
    "pkg:gem/#{name}@#{version}"
  end

  def self.config(options = {})
    if !options[:user].nil? && !options[:token].nil?
      Chelsea::OSSIndex.new(
        options: {
          oss_index_user_name: options[:user],
          oss_index_user_token: options[:token]
        }
      )
    else
      Chelsea::OSSIndex.new(options: oss_index_config)
    end
  end

  def self.client(options = {})
    @client ||= config(options)
    @client
  end

  def self.oss_index_config
    if !File.exist? File.join(@oss_index_config_location, @oss_index_config_filename)
      { oss_index_user_name: '', oss_index_user_token: '' }
    else
      conf_hash = YAML.safe_load(
        File.read(
          File.join(@oss_index_config_location, @oss_index_config_filename)
        )
      )
      {
        oss_index_user_name: conf_hash['Username'],
        oss_index_user_token: conf_hash['Token']
      }
    end
  end

  def get_white_list_vuln_config(white_list_config_path)
    if white_list_config_path.nil?
      YAML.safe_load(File.read(File.join(Dir.pwd, 'chelsea-ignore.yaml')))
    else
      YAML.safe_load(File.read(white_list_config_path))
    end
  end

  def self.read_oss_index_config_from_command_line
    config = {}

    puts 'What username do you want to authenticate as (ex: your email address)? '
    config['Username'] = STDIN.gets.chomp

    puts 'What token do you want to use? '
    config['Token'] = STDIN.gets.chomp

    _write_oss_index_config_file(config)
  end

  def self._write_oss_index_config_file(config)
    unless File.exist? @oss_index_config_location
      Dir.mkdir(@oss_index_config_location)
    end
    File.open(File.join(@oss_index_config_location, @oss_index_config_filename), "w") do |file|
      file.write config.to_yaml
    end
  end
end