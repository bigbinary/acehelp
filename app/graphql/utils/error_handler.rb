# frozen_string_literal: true

class Utils::ErrorHandler
  def generate_graphql_error_with_root(message, path:, extensions: {})
    path = [path] if path.is_a?(String)
    {
        data: nil,
        errors: [
            {
                message: message,
                path: path,
                extensions: extensions
            }
        ]
    }
  end

  def generate_error_hash(message, context, attributes: [])
    [
      {
        message: message,
        path: [context.key] + attributes
      }
    ]
  end

  def generate_detailed_error_hash(object, context, general_message: nil)
    if object.respond_to?(:errors) && object.errors.present?
      object.errors.map do |attribute, message|
        attribute = attribute.to_s
        {
          path: [context.key, 'attribute', attribute],
          message: general_message || "#{attribute} #{message}"
        }
      end
    end
  end

end
