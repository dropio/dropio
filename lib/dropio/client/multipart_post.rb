module Dropio::Client::MultipartPost
  def multipart_params=(param_hash={})
    boundary_token = [Array.new(8) {rand(256)}].join
    self.content_type = "multipart/form-data; boundary=#{boundary_token}"
    boundary_marker = "--#{boundary_token}\r\n"
    self.body = param_hash.map { |param_name, param_value|
      unless param_value.nil?
        boundary_marker + case param_value
        when String
          text_to_multipart(param_name, param_value.to_s)
        when File
          file_to_multipart(param_name, param_value)
        end
      end
    }.join('') + "--#{boundary_token}--\r\n"
  end

  protected
  def file_to_multipart(key,file)
    filename = File.basename(file.path)
    mime_types = MIME::Types.of(filename)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    part = "Content-Disposition: form-data; name=\"#{key}\"; filename=\"#{filename}\"\r\n"
    part += "Content-Transfer-Encoding: binary\r\n"
    part += "Content-Type: #{mime_type}\r\n\r\n#{file.read}\r\n"
  end

  def text_to_multipart(key,value)
    "Content-Disposition: form-data; name=\"#{key}\"\r\n\r\n#{value}\r\n"
  end
end

class Net::HTTP::Post
  include Dropio::Client::MultipartPost
end
