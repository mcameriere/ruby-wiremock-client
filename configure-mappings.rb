require './configurable_mapping'

def refresh 
    @configurable_mappings = ConfigurableMapping.get_configurable_mappings
    @configurable_mappings.each_with_index do |configurable_mapping, index|
        s = "[\e[32m#{index.to_s}\e[0m] "
        s+= "\e[33m#{configurable_mapping.mapping['request']['url']}\e[0m"
        s+= " [\e[34m#{configurable_mapping.active_response}\e[0m]"
        s+= " configurable to #{configurable_mapping.responses.to_s}"
        puts s
    end
end

refresh

configurable_mapping_index = ''
while configurable_mapping_index != 'q'
    print "Index? "
    configurable_mapping_index = gets.chomp
    break if configurable_mapping_index == 'q'
    puts "Configure \e[33m#{@configurable_mappings[configurable_mapping_index.to_i].mapping['request']['url']}\e[0m"
    @configurable_mappings[configurable_mapping_index.to_i].responses.each_with_index do |response, index|
        s = "[\e[32m#{index.to_s}\e[0m] "
        s+= "#{response}"
        puts s
    end
    print "Response? "
    response_index = gets.chomp
    break if response_index == 'q'
    @configurable_mappings[configurable_mapping_index.to_i].select_response(@configurable_mappings[configurable_mapping_index.to_i].responses[response_index.to_i])
    refresh
end
