# frozen_string_literal: true

Scalars::FileType = GraphQL::ScalarType.define do
  name "File Upload"
  description "action_dispatch_uploaded_file"
  coerce_input lambda { |file, _ctx|
    ActionDispatch::Http::UploadedFile.new(
      filename: file.original_filename,
      type: file.content_type,
      head: file.headers,
      tempfile: file.tempfile,
    )
  }
end
