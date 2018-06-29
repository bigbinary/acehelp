module Utils
  class ErrorHandler

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

    def object_error_full_messages(obj)
      "Invalid Input: #{obj.errors.full_messages.join(', ')}"
    end
  end
end
