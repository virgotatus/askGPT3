class PromptsController < ApplicationController
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
    @prompt = Prompt.find(params[:prompt_id])  # need a prompt_id
    body = params[:prompt][:body]
    @prompt.update(body: body)
    ai_result = get_ai(body +". your answer is:")
    ai_result = ai_result[0]  # index 0 of reply array
    print "ai_result:", ai_result , "\n"
    begin 
      audio_url = speak_ai(ai_result)
    rescue => e
      puts "no audio"
      audio_url = nil
    end
    print "audio url:", audio_url, "\n"
    if defined?(@prompt.reply.body)
      @prompt.reply.body = ai_result
      @prompt.reply.radio_url = audio_url
      puts "update prompt's reply"
      @prompt.reply.save
    else
      @prompt.reply = Reply.new(body: ai_result, prompt: @prompt, radio_url: audio_url)
    end

    @data = { answer: ai_result, audio_src_url: audio_url }
    render json: @data
  end

  def get_ai(prompt_text)
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

  def speak_ai(text)
    require 'resemble'
    Resemble.api_key = ENV['RESEMBLE_API_TOKEN']
    project_uuid = ENV['RESEMBLE_PROJECT_UUID']
    voice_uuid = ENV['RESEMBLE_VOICE_UUID']
    callback_uri = 'https://example.com/callback/resemble-clip'
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
    puts "create async audio ", response["success"] ? "" : response["message"]
    clip_uuid = response['item']['uuid']
    sleep(5)  # async
    response = Resemble::V2::Clip.get(project_uuid, clip_uuid)
    puts "get audio ", response["success"] ? response["item"]["uuid"] : response["message"]
    audio_src = response["item"]["audio_src"]
  end

  private
    def prompt_params
      # note that initilize using attributes of params
      params.require(:prompt).permit(:title, :body,
       detail_attributes: [:imgname, :imglink, :description, :alter_questions])
    end
end
