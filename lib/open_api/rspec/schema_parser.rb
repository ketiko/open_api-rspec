# frozen_string_literal: true

module OpenApi
  module RSpec
    class SchemaParser
      attr_reader :openapi_schema, :request, :response, :schema_for_url
      UUID_REGEX = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'

      def initialize(openapi_schema, request, response)
        @openapi_schema = openapi_schema
        @request = request
        @response = response

        url = request.path.gsub(@openapi_schema['basePath'], '')
        url_fragments = url.split('/')

        @openapi_schema['paths'].each do |path, meta|
          path_fragments = path.to_s.split('/')
          next if path_fragments.count != url_fragments.count

          mismatch = false
          @request_path_params = {}
          path_fragments.each_with_index do |a, i|
            if has_documented_param_in_openapi_url_fragments(a)
              openapi_for_http_method = meta[request.method.to_s.downcase.to_s]
              unless openapi_for_http_method
                mismatch = true
                break
              end
              openapi_params = openapi_for_http_method['parameters']
              unless openapi_params
                mismatch = true
                break
              end
              openapi_path_params = openapi_params.select do |path_param|
                path_param['in'].to_s == 'path'
              end
              unless openapi_path_params
                mismatch = true
                break
              end
              meta_param = openapi_path_params.find do |path_param|
                path_param['name'].to_s == openapi_url_fragment_name(a).to_s
              end
              if meta_param
                case meta_param['type'].to_s
                when 'integer'
                  if (url_fragments[i] =~ /\d/) != 0
                    mismatch = true
                    break
                  else
                    @request_path_params[a.delete('{').delete('}')] = url_fragments[i]
                    next
                  end
                when 'string'
                  if (url_fragments[i] =~ /#{UUID_REGEX}/) != 0 &&
                     (url_fragments[i] =~ /[a-zA-Z]+/) != 0

                    mismatch = true
                    break
                  else
                    @request_path_params[a.delete('{').delete('}')] = url_fragments[i]
                    next
                  end
                else
                  mismatch = true
                  break
                end
              else
                mismatch = true
                break
              end
            end

            mismatch = a != url_fragments[i]
            break if mismatch
          end

          next if mismatch

          @schema_for_url = meta

          break
        end
      end

      def has_documented_param_in_openapi_url_fragments(fragment)
        (fragment =~ /^{.+}$/) == 0
      end

      def openapi_url_fragment_name(fragment)
        fragment.match(/^{(.+)}$/).captures.first
      end

      def request_path_params
        @request_path_params.map { |k, _| k.to_s }
      end

      def schema_for_url_and_request_method
        if schema_for_url
          schema_for_url[request.method.to_s.downcase.to_s]
        else
          {}
        end
      end

      def schema_for_url_and_request_method_parameters
        schema_for_url_and_request_method['parameters'] || [{}]
      end

      def schema_for_url_and_request_method_query_string_parameters
        schema_for_url_and_request_method_parameters
          .select { |p| p['in'].to_s == 'query' }
      end

      def schema_for_url_and_request_method_path_parameters
        schema_for_url_and_request_method_parameters
          .select { |p| p['in'].to_s == 'path' }
      end

      def schema_for_url_and_request_method_form_data_parameters
        schema_for_url_and_request_method_parameters
          .select { |p| p['in'].to_s == 'formData' }
      end

      def schema_for_url_and_request_method_body_parameters
        schema_for_url_and_request_method_parameters
          .select { |p| p['in'].to_s == 'body' }
      end

      def schema_for_url_and_request_method_and_response_status
        if schema_for_url_and_request_method['responses']
          schema = schema_for_url_and_request_method['responses'][response.status.to_s]
          schema
        else
          {}
        end
      end

      def openapi_query_string_params
        schema_for_url_and_request_method_query_string_parameters.map { |p| p['name'].to_s }
      end

      def openapi_path_params
        schema_for_url_and_request_method_path_parameters.map { |p| p['name'].to_s }
      end

      def openapi_form_data_params
        schema_for_url_and_request_method_form_data_parameters.map { |p| p['name'].to_s }
      end

      def openapi_body_params
        schema_for_url_and_request_method_body_parameters.flat_map do |p|
          if p['schema'].present?
            scheme = p['schema']['$ref'].tr('/', ' ')[2..-1].strip.split.map(&:to_s)
            body = @openapi_schema.dig(*scheme)
            body['properties'].flat_map do |k, v|
              deep_body_keys(k, v)
            end
          else
            p['name'].to_s
          end
        end
      end

      def deep_body_keys(name, hash)
        if hash['type'] == 'object'
          hash['properties'].flat_map do |p_name, p_hash|
            parent = name.to_s.camelize(:lower).to_s
            sub_keys = deep_body_keys(p_name, p_hash)
            sub_keys.flat_map do |sub|
              "#{parent}##{sub}".to_s
            end
          end
        else
          [name.to_s.camelize(:lower).to_s]
        end
      end

      def openapi_request_params
        [
          openapi_query_string_params,
          openapi_path_params,
          openapi_form_data_params,
          openapi_body_params
        ].flatten.compact
      end

      def openapi_required_form_data_params
        schema_for_url_and_request_method_form_data_parameters
          .select { |p| p['required'] == true }
          .map { |p| p['name'].to_s }
      end

      def openapi_required_path_params
        schema_for_url_and_request_method_path_parameters
          .select { |p| p['required'] == true }
          .map { |p| p['name'].to_s }
      end

      def openapi_required_query_string_params
        schema_for_url_and_request_method_query_string_parameters
          .select { |p| p['required'] == true }
          .map { |p| p['name'].to_s }
      end

      def request_params
        valid_params = get_deep_keys(request.params.except('format', 'action', 'controller'))

        valid_params - request_path_params
      end

      def get_deep_keys(hash)
        return [] if hash.empty?

        hash.flat_map do |k, v|
          if v.is_a? Hash
            parent = k.to_s.camelize(:lower).to_s
            sub_keys = get_deep_keys(v)
            sub_keys.map do |sub|
              "#{parent}##{sub}".to_s
            end
          else
            k.to_s.camelize(:lower).to_s
          end
        end
      end
    end
  end
end
