class Idea < ApplicationRecord
  validates :city, presence: true
  validates :thing, presence: true

  def construct_prompt
    style = "create a haiku, then explain it longer according to the card, in humour style. "
    seed = Random.new(Time.now.to_i)
    oblique_word = OBLIQUES[seed.rand(100)]
    body = "with Brian Eno's oblique strategies card:'#{oblique_word}', 
use zone:'#{self.city}' and thing:'#{self.thing}' as metaphor to #{style}
speak as locale-#{self.locale} language. your answer is:"
    update(style: style, oblique: oblique_word)
    body
  end
end
