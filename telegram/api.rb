module Telegram::Action
  TYPING = "typing"
  UPLOAD_PHOTO = "upload_photo"
end

module Telegram::API
  def me
    Telegram::Client.instance.get("getMe")
  end

  def send_message(whom, text, entities: nil, reply_markup: nil)
    chat_id =
      case whom
      in Integer           then whom
      in id: Integer => id then id
      end

    Telegram::Client.instance.post("sendMessage", chat_id:, text:, entities:, reply_markup:)
  end

  def send_media_group(whom, media, caption: nil)
    chat_id =
      case whom
      in Integer           then whom
      in id: Integer => id then id
      end

    media.first[:caption] = caption if caption

    Telegram::Client.instance.post "sendMediaGroup", chat_id:, media:
  end

  def get_file(file_id)
    Telegram::Client.instance.get("getFile", file_id:)
  end

  def send_chat_action(whom, action)
    chat_id =
      case whom
        in Integer           then whom
        in id: Integer => id then id
      end

    Telegram::Client.instance.post("sendChatAction", chat_id:, action:)
  end
end
