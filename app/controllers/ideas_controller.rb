class IdeasController < ApplicationController
  def index
    @idea = Idea.new
    
  end

  def ask_ai
    city = params[:city]
    thing = params[:thing]
    style_index = Time.now.wday
    style = "using homour style."
    seed = Random.new(Time.now.to_i)
    oblique_word = OBLIQUES[seed.rand(100)]
    puts oblique_word
    body = "use words '#{city}', '#{thing}', '#{oblique_word}' , to make a longer explanation of idea generating, speak as Chinese language."
    body += style
    ai_result = get_ai(body +" your answer is:")
    ai_result = ai_result[0]  # index 0 of reply array

    @data = { oblique: oblique_word, answer: ai_result }
    render json: @data
  end

  def get_ai(prompt_text)
    client = OpenAI::Client.new
    response = client.completions(
        parameters: {
            model: "text-davinci-003",
            prompt: prompt_text,
            max_tokens: 200
        })
    puts response["choices"]
    result = response["choices"].map { |c| c["text"] }
  end

end
