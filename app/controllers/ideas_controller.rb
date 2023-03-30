class IdeasController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:baixing]
  def index
    @idea = Idea.new
  end

  def ask_ai
    city = params[:idea][:city]
    thing = params[:idea][:thing]
    locale = extract_locale_from_accept_language_header
    @idea = Idea.new(city: city, thing: thing, locale: locale)
    if @idea.save
      session[:current_idea_id] = @idea.id
    else
      logger.debug "save failed, error:#{@idea.errors.full_messages.join(", ")}"
    end
    prompt = @idea.construct_prompt
    logger.info "request idea saved. city:#{city}, thing:#{thing}, locale:#{locale}, oblique:#{@idea.oblique}, prompt:#{prompt}\n"
    ai_result = get_ai(prompt)
    if (ai_result == nil)
      logger.debug "get ai result nil, failed!"
      render status: :unprocessable_entity
      @idea.delete
      return
    end
    logger.info "ai result: #{ai_result}"
    @idea.update(answer: ai_result)

    @data = { oblique: @idea.oblique, answer: ai_result }
    render json: @data
  end

  def send_email
    email = params[:email]
    @idea = current_idea()
    logger.info "email to #{email}: #{@idea.id}, #{@idea.city}, #{@idea.thing}, #{@idea.oblique}, #{@idea.answer}"
    @idea.update(email: email)
    NotifierMailer.with(idea: @idea).notify_email(email).deliver_now
    session.delete(:current_idea_id)
    @_current_idea = nil
    render json: {}, status: :no_content
  end

  def get_ai(prompt_text)
    client = OpenAI::Client.new
    role_chat = [
      {"role": "system", "content": "you are a creator on philosophy and art, like Brian Eno."},
      {"role": "user", "content": "with oblique strategies card:'Tidy up', use zone:'客厅' and thing:'老虎'as metaphor and create a haiku,
        then explain it longer according to the card, in humour style. speak in Chinese language more."},
      {"role": "assistant", "content": "\n\n老虎在客厅收拾，\n 清理整齐乐不思蜀；\n把烦恼都抛开，\n心情舒畅自由自在。\n\n将客厅整理是让人怦然心动的魔法，心情舒畅，甩开膀子，丢开烦恼，就像一只老虎在房间里跳舞施法，咻咻咻！创作是整理的同时加上丢开枷锁，让自己自由自在地享受快乐的时光。"},
      {"role": "user", "content": "with oblique strategies card:'Retrace your steps', use zone:'客厅' and thing:'老虎'as metaphor and create a haiku,
        then explain it longer according to the card, in humour style. speak as Chinese language more."},
      {"role": "assistant", "content": "\n\n曲折路径老虎在客厅，\n原來是回到发端。\n走了许多步才到终点，\n就像老虎在客厅跳跃，\n漫長的旅程讓我們深思，\n但若能重新踏上原路，\n終究可以達到目標！\n\n想想你的初心是什么吧，回归初心，总是会发现更多东西，不管是屎还是灵感，都如孩童般纯真调皮。"},
      {"role": "user", "content": "with oblique strategies card:'Be dirty', use zone:'舞厅' and thing:'银渐层猫'as metaphor and create a haiku,
        then explain it longer according to the card, in humour style. speak as Chinese language more."},
      {"role": "assistant", "content": "\n\n哗哗舞厅里，\n银渐层在跳动，\n猫爪染上污。\n银渐层猫是银白色的吗？！然而在舞厅忘我的舞蹈创造中，它亦不惧将双足弄脏，反而有种纯与污之美。创作是不惧怕混乱糟糕的，勇敢的将自己投入到脏脏中，也许会收收获别样的美感与灵动。打破常规，跳开正经的束缚，Let's be dirty baby! "},
    ]
    response = client.chat(
        parameters: {
            model: "gpt-3.5-turbo",
            messages: role_chat + [{ "role": "user", "content": prompt_text}],
            temperature: 0.7,
            max_tokens: 512,
        })
    if response["error"]
      raise RuntimeError, response["error"]
      return 
    end
    result = response.dig("choices", 0, "message", "content")
    
    # response = client.completions(
    #     parameters: {
    #         model: "text-davinci-003",
    #         prompt: prompt_text,
    #         max_tokens: 512,
    #         temperature: 0.7,
    #     })
    # result = response["choices"].map { |c| c["text"] }
    # result = result[0]  # index 0 of reply array
  end

  def baixing
    p = params[:p]
    qid = params[:qid]
    uid = params[:uid]
    city, thing = p.split(/[,，]/)
    if (city==nil or thing == nil)
      render json: {"data": {"type": "text", "content": "调皮，输入格式不对哦，别调戏我~~请认真对待"}}
      return
    end
    @idea = Idea.new(city: city, thing: thing)
    if @idea.save
      session[:current_idea_id] = @idea.id
    else
      logger.debug "save failed, error: #{@idea.errors.full_messages.join(", ")}"
    end
    prompt = @idea.construct_prompt
    ai_result = get_ai(prompt)
    @idea.update(answer: ai_result, email: "hackathon-hf@baixing.com")
    logger.info "baixing api: generate idea successful, city:#{city}, thing:#{thing}, oblique:#{@idea.oblique},
     prompt:#{prompt} answer:#{ai_result} \n"
    template = File.read(Rails.root.join('app', 'views', 'notifier_mailer','notify_email.text.erb'))
    renderer = ERB.new(template)
    result = renderer.result(binding)
    @data = {"data": {"type": "text", "content": result}}
    render json: @data
  end

  private
  # Finds the Idea with the ID stored in the session with the key
  # :current_idea_id This is a common way to handle user login in
  # a Rails application; logging in sets the session value and
  # logging out removes it.
  def current_idea
    @_current_idea ||= session[:current_idea_id] &&
      Idea.find_by(id: session[:current_idea_id])
  end
  # locale from language header
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
end
