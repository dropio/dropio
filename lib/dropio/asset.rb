class Dropio::Asset
  include Dropio::Model
  attr_accessor :name, :type, :title, :description, :filesize, :created_at,
                :thumbnail, :status, :file, :converted, :hidden_url, :pages,
                :duration, :artist, :track_title, :height, :width, :contents, :url
end