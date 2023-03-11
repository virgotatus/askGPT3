class Reply < ApplicationRecord
  # reply of GPT , including answer and audio_url by resemble.ai
  belongs_to :prompt
end
