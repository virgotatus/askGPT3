class PromptsController < ApplicationController
  include EmbeddingProcess
  skip_before_action :verify_authenticity_token, only: [:async_callback_resemble]

  def index
    @prompts = Prompt.all
  end

  def show 
    @prompt = Prompt.find(params[:id])
  end

  def new
    @prompt = Prompt.new
  end

  def create
    @prompt = Prompt.new(prompt_params)
    if @prompt.save
      redirect_to @prompt
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @prompt = Prompt.find(params[:id])
  end

  def update
    @prompt = Prompt.find(params[:id])
    if (@prompt.detail != nil && prompt_params.has_key?(:detail_attributes))
      @prompt.detail.update(prompt_params[:detail_attributes])
    end
    if @prompt.update(title: prompt_params[:title], body: prompt_params[:body])
      redirect_to @prompt
    else
      puts "update error; redirect to edit"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy 
    @prompt = Prompt.find(params[:id])
    if (@prompt.detail != nil)
      @prompt.detail.destroy
    end
    if (@prompt.reply != nil)
      @prompt.reply.destroy
    end
    @prompt.destroy

    redirect_to root_path, status: :see_other
  end

  def ask_ai
    # this route was replaced by ask_ai_with_embedding
    @prompt = Prompt.find(params[:prompt_id])  # need a prompt_id
    body = params[:prompt][:body]
    @prompt.update(body: body)
    ai_result = get_completion_ai(body +". your answer is:")
    ai_result = ai_result[0]  # index 0 of reply array
    print "ai_result:", ai_result , "\n"
    begin 
      clip_uuid, audio_url = speak_ai(ai_result)
    rescue => e
      puts "no audio"
      audio_url = nil
    end
    print "audio url:", audio_url, "\n"
    if defined?(@prompt.reply.body)
      @prompt.reply.update(body: ai_result, radio_url: audio_url, audio_uuid: clip_uuid)
      puts "update prompt's reply"
    else
      @prompt.reply = Reply.new(body: ai_result, prompt: @prompt, radio_url: audio_url, audio_uuid: clip_uuid)
      @prompt.reply.save
    end

    @data = { answer: ai_result, audio_src_url: audio_url }
    render json: @data
  end

  def get_completion_ai(prompt_text)
    client = OpenAI::Client.new
    response = client.completions(
        parameters: {
            model: "text-davinci-003",
            prompt: prompt_text,
            max_tokens: 10
        })
    puts response["choices"]
    result = response["choices"].map { |c| c["text"] }
  end

  def ask_with_embeddings
    # converted from python code: lib/tasks/ask_ai_with_embedding.py
    # inplement search previous question and construct prompt including similar context by openai-embedding. 
    @prompt = Prompt.find(params[:prompt_id])  # need a prompt_id
    body = params[:prompt][:body]
    if !body.end_with?("?")
      body += "?"
    end

    previous_question = Prompt.where(body: body).first
    audio_src_url = (previous_question and previous_question.reply and previous_question.reply.radio_url)
    @prompt.update(body: body) # note a probably bug: prompt update should after at finding previous_question, or it will find itself.
    if audio_src_url
      print("previously asked and answered: " + previous_question.reply.body + " ( " + previous_question.reply.radio_url + ")")
      @prompt.reply.update(body: previous_question.reply.body, radio_url: previous_question.reply.radio_url)
      render json: {"answer": previous_question.reply.body , "audio_src_url": audio_src_url, "audio_uuid": previous_question.reply.audio_uuid }
      return 
    end
    # can't find previous question so create new by asking GPT
    exampleQA = ExampleQA.new(header=HEADER, list_QA=LIST_QA)
    df = PageFrame.new(BOOK_PAGES_PATH)
    document_embeddings = load_embeddings(BOOK_EMBEDDINGS_PATH)
    answer, context = answer_query_with_context(body, df, document_embeddings, exampleQA, max_tokens=50)
    audio_uuid = speak_ai(answer)

    print("new asked and answer:" + answer + "(" + audio_uuid + ")")
    if @prompt.reply == nil
      @prompt.reply = Reply.new(body: answer, audio_uuid: audio_uuid)
      @prompt.save
    else
      @prompt.reply.update(body: answer, audio_uuid: audio_uuid )
    end

    render json: {"answer": @prompt.reply.body , "audio_uuid": audio_uuid }
  end

  def speak_ai(text)
    # create audio sounds by resemble.ai, need sync response but async now because of no money...
    require 'resemble'
    Resemble.api_key = ENV['RESEMBLE_API_TOKEN']
    project_uuid = ENV['RESEMBLE_PROJECT_UUID']
    voice_uuid = ENV['RESEMBLE_VOICE_UUID']
    callback_uri = ENV['DEPLOY_ADDRESS']+'/prompts/resemble_callback'
    response = Resemble::V2::Clip.create_async(
      project_uuid,
      voice_uuid,
      callback_uri,
      text,
      title: nil,
      sample_rate: nil,
      output_format: nil,
      precision: nil,
      include_timestamps: nil,
      is_public: nil,
      is_archived: nil
    )
    print("create async audio ", response["success"] ? "succeed!" : response["message"])
    clip_uuid = (response["success"] ? response['item']['uuid'] : "")
    return clip_uuid
  end

  def async_callback_resemble
    clip_uuid = params[:id]
    audio_src_url = params[:url]
    reply = Reply.where(audio_uuid: clip_uuid).first
    if reply != nil
      reply.update(radio_url: audio_src_url) # update reply record
      puts "resemble callback async! update audio_url"
    end
    ActionCable.server.broadcast("voice_#{clip_uuid}", { "audio_src_url": audio_src_url })
    render json: {"audio_src_url": audio_src_url }, status: :ok
  end

  private
    def prompt_params
      # note that initialize using attributes of params
      params.require(:prompt).permit(:title, :body,
       detail_attributes: [:imgname, :imglink, :description, :alter_questions])
    end
end
