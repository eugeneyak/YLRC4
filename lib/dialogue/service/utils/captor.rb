class Dialogue::Service::Utils::Captor
  extend Interactor

  use Middleware::Spanable
  use Middleware::Loggable

  def initialize(photos, caption: "", entities: [])
    @photos = photos
    @caption = caption
    @entities = entities
  end

  attr_reader :photos, :caption, :entities

  def call
    photos.map.with_index do |photo, index|
      if index.zero?
        generate photo, caption_entities: entities, caption: caption
      else
        generate photo
      end
    end
  end

  def generate(photo, caption: nil, caption_entities: nil)
    {
      type: "photo",
      media: photo,
      caption: caption,
      caption_entities: caption_entities,
      show_caption_above_media: true
    }.compact
  end
end
