require 'rest-client'
require 'json'
require 'pathname'

class ConfigurableMapping
    
    def initialize(mapping, active_response, responses)
        @mapping = mapping
        @active_response = active_response
        @responses = responses
    end

    def mapping
        @mapping
    end

    def active_response
        @active_response
    end

    def responses
        @responses
    end

    def select_response(file_name)
        if @responses.include?(file_name)
            update_mapping(file_name)
        else
            raise ArgumentError, "Unknown response #{file_name}"
        end
    end

    def update_mapping(file_name)
        payload = alternate_mapping(file_name)
        RestClient.put "http://localhost:7080/__admin/mappings/#{@mapping['id']}", payload.to_json
    end
    
    def alternate_mapping(file_name)
        inital_body_file_name = @mapping['response']['bodyFileName']
        path_name = Pathname.new(inital_body_file_name)
        dir_name = path_name.dirname
        json_file = path_name.basename
        @mapping['response']['bodyFileName'] = "#{dir_name}/#{file_name}"
        return @mapping
    end

    def ConfigurableMapping.get_configurable_mappings
        all_mappings = JSON.parse(RestClient.get 'http://localhost:7080/__admin/mappings')
        configurable_mappings = Array.new
        all_mappings['mappings'].each do |mapping|
            body_file_name = mapping['response']['bodyFileName']
            if body_file_name != nil
                path_name = Pathname.new(body_file_name)
                dir_name = path_name.dirname
                active_response_file_name = path_name.basename.to_s
                configurable_responses = Dir.children("__files/#{dir_name}")
                if configurable_responses.length > 1
                    configurable_mapping = ConfigurableMapping.new(mapping, active_response_file_name, configurable_responses)
                    configurable_mappings.push(configurable_mapping)
                end
            end
        end
        configurable_mappings
    end
    
end
