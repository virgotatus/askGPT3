class IdeasController < ApplicationController
  def index
    @idea = Idea.new
    
  end

  def ask_ai
    city = params[:idea][:city]
    thing = params[:idea][:thing]
    style_index = Time.now.wday
    style = "创作一组俳句."
    seed = Random.new(Time.now.to_i)
    oblique_word = OBLIQUES[seed.rand(100)]
    puts oblique_word
    body = "use words '#{city}' and '#{thing}' as a metaphor.'#{style}' 
     make a longer explanation of this brian eno's oblique strategies card:'#{oblique_word}', to generate idea.
     speak as Chinese language."
    ai_result = get_ai(body +" your answer is:")
    ai_result = ai_result[0]  # index 0 of reply array

    print "body: ", body
    @idea = Idea.new(city: city, thing: thing, style: style, oblique: oblique_word, answer: ai_result)
    if @idea.save
      puts "save idea successful"
    else
      print "save failed:", @idea.errors.full_messages.join(", ")
    end

    @data = { oblique: oblique_word, answer: ai_result }
    render json: @data
  end

  def get_ai(prompt_text)
    client = OpenAI::Client.new
    response = client.completions(
        parameters: {
            model: "text-davinci-003",
            prompt: prompt_text,
            max_tokens: 500
        })
    puts response["choices"]
    result = response["choices"].map { |c| c["text"] }
  end

end
