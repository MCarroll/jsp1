module Jumpstart
  module YAMLSerializer
    # A simple YAML serializer that does not support nested elements

    module_function

    def load(path)
      result = {}
      key = nil
      multiline = false

      File.readlines(path, chomp: true).each do |line|
        # multiline hash key
        if (match = /^(\w+):\s*\|-/.match(line))
          multiline = true
          key = match[1]
          result[key] = ""

        # hash keys
        elsif (match = /^(\w+):\s*(.*)/.match(line))
          multiline = false
          key, value = match[1], match[2]
          result[key] = value unless value.empty?

        # array entries
        elsif line.start_with? "- "
          result[key] ||= []
          result[key] << line.delete_prefix("- ")

        # multiline string
        elsif multiline
          result[key] += "\n" unless result[key].empty?
          result[key] += line.strip
        end
      end

      result
    end

    def dump(object)
      yaml = "---\n"
      object.instance_variables.each do |ivar|
        key = ivar.to_s.delete_prefix("@")
        value = object.instance_variable_get(ivar)
        yaml << key << ":"

        if value.is_a?(Array)
          yaml << value.map { |e| "\n- #{e.to_s.gsub(/\s+/, " ")}" }.join << "\n"
        elsif value.is_a?(String) && value.include?("\n")
          yaml << " |-\n  " << value.split("\n").join("\n  ") << "\n"
        else
          yaml << " " << value.to_s.gsub(/\s+/, " ") << "\n"
        end
      end

      yaml
    end

    def dump_to_file(path, object)
      File.write(path, dump(object))
    end
  end
end
