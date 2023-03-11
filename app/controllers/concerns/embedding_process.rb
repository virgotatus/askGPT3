# this module was converted from python code: lib/tasks/ask_ai_with_embedding.py
module EmbeddingProcess
  extend ActiveSupport::Concern

  COMPLETIONS_MODEL = "gpt-3.5-turbo"
  EMBEDDINGS_MODEL = "text-embedding-ada-002"
  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "
  SEPARATOR_LEN = 3

  class ExampleQA
    def initialize(header, list_QA)
      @header = header
      @list_QA = list_QA
    end
    def get_QA
      @list_QA
    end
    def get_header
      @header
    end
  end

  def dot_product(a, b)
    raise "Arrays must have the same length" unless a.length == b.length
    sum = 0
    a.each_index { |i| sum += a[i] * b[i] }
    sum
  end

  class PageFrame
    def initialize(file_path)
      @csv = CSV.read(file_path, headers:true, converters: :numeric, header_converters: :symbol)
      @size = @csv.size
    end
    def find_by_title(title)
      index = @csv[:title].find_index(title)
      raise ArgumentError, "can't find title, check if it exists." if index == nil
      @csv[index]
    end
    def get_id(idx)
      raise IndexError, "index out of bound." unless idx < @size
      @csv[idx]
    end
  end

  def load_embeddings(file_path)
    result = {}
    csv = CSV.read(file_path, headers:true, converters: :float)
    csv.each do |row|
      result[row[0]] = row[1..4096].compact
    end
    result
  end

  def get_embedding_ai(text)
    client = OpenAI::Client.new
    response = client.embeddings(
        parameters: {
            model: EMBEDDINGS_MODEL,
            input: text
        })
    result = response['data'][0]['embedding']
  end

  def order_document_sections_by_query_similarity(query, contexts)
    # Find the query embedding for the supplied query, and compare it against all of the pre-calculated document embeddings
    # to find the most relevant sections.
    # Return the list of document sections, sorted by relevance in descending order.
    
    query_embedding = get_embedding_ai(query)
    document_similarities = contexts.map{|doc_index, doc_embedding| [dot_product(query_embedding, doc_embedding), doc_index]}.sort_by{|pair| -pair[0]}
    document_similarities
  end

  def construct_message(question, context_embeddings, df, example_QA)
    # Fetch relevant embeddings and construct message by system, user, assistant roles, which is supported in new gpt-3.5-turbo.
    most_relevant_document_sections = order_document_sections_by_query_similarity(question, context_embeddings)

    chosen_sections = []
    chosen_sections_len = 0
    chosen_sections_indexes = []

    most_relevant_document_sections.each do |_, section_index|
        document_section = df.find_by_title(section_index)

        chosen_sections_len += document_section[:tokens] + SEPARATOR_LEN
        if chosen_sections_len > MAX_SECTION_LEN
            space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR_LEN
            chosen_sections.append(SEPARATOR + document_section[:content][0..space_left])
            chosen_sections_indexes.append(section_index.to_s)
            break
        end

        chosen_sections.append(SEPARATOR + document_section[:content])
        chosen_sections_indexes.append(section_index.to_s)
    end
    message = [{"role": "system", "content": example_QA.get_header + chosen_sections.join("")}]
    example_QA.get_QA.each do |qa|
      message += [{"role": "user", "content": qa[:Q]}]
      message += [{"role": "assistant", "content": qa[:A]}]
    end
    message += [{"role": "user", "content": question}]
    return message, chosen_sections.join("")
  end

  def answer_query_with_context(query, df, document_embeddings, example_QA)
    # call new gpt-3.5-turbo and chat to get answer
    message, context = construct_message(query, document_embeddings, df, example_QA)
    # print("===\n", prompt)
    client = OpenAI::Client.new
    response = client.chat(
        parameters: {
            model: COMPLETIONS_MODEL,
            messages: message,
            max_tokens: 150,
            temperature: 0.0,
        })
    print( "call OpenAI::Chat: ", response.dig("choices", 0, "message", "content"))
    result = response.dig("choices", 0, "message", "content")
    return result, context
  end

end