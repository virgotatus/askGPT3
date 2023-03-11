class Detail < ApplicationRecord
  # prompts's detail like img name and img_link, alter questions, description
  belongs_to :prompt
end
