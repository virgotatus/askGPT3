class Idea < ApplicationRecord
  validates :city, presence: true
  validates :thing, presence: true
  attr_accessor :oblique

  def construct_prompt
    style = "create a haiku"
    seed = Random.new(Time.now.to_i)
    oblique_word = OBLIQUES[seed.rand(100)]
    puts oblique_word
    body = "with brian eno's oblique strategies card:'#{oblique_word}', 
    use zone:'#{self.city}' and thing:'#{self.thing}' as metaphor and #{style}, then explain it longer according to the card, in humour style. speak in Chinese language more. your answer is:"
    update(style: style, oblique: oblique_word)
    body
  end
end
