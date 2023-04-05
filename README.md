# README

A askGPT project.

Use ruby on rails. Deploy on AWS cloud by puma and Nginx. Use OpenAI GPT model API.

- **Project1-Ask My Book. Refer to https://github.com/slavingia/askmybook/**
  - create and edit question for books, like "The minimalist entrepreneur" 
  - find previous question, if not have, reply a new answer by openai:completions, with prompts constructed by embedding context. calculate language similarity by openai:embedding vector cosine similarity.
  - use **gpt-3.5-turbo model (openai:chat)**
  - use python script to create book context data-frame of pages and embedding. usage: lib/tasks/pdf_to_pages_embedding.py
  - deploy: http://asky.ideaplayer.shop/prompts/

- **Project2 Stochastic Idea Player. Inspired by Idea Buyer Club（灵感买家俱乐部）**
  - input two words like zone and thing, output a random oblique strategies card. and then explain it longer with OpenAI-GPT3.
  - you can send it to your email-address or share picture on social media.
  - it's a cyber-psychic rites. it needs a role like me to reflect your feelings and link the imagination between this   explaination and your question/goals. I'm a part-time psycho-counselor.
  - take it seriously.
  - deploy: http://asky.ideaplayer.shop

Things you may want to cover:

* Ruby version: 3.1.3p185

* System dependencies
  - linux (aws, aliyun)
  - windows

* Configuration
  - rewrite your env.example to .env, which including: OPENAI_API_TOKEN and RESEMBLE_AI_API, WY_MAIL_SMTP

* Database creation
  - splite3 , cmd: rails db:migrate

* Database initialization
  - python read book-pdf: python pdf_to_pages_embedding.py -pdf yourbook.pdf
  - write some question and answer with chat context in config/initializers/my_book.rb
  - book.pdf , book.pdf.pages.csv and book.pdf.embeddings.csv should be store at /storage folder.

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)
  - config your nginx_config
  - config puma.rb 

* Deployment instructions
  - bundle install
  - service nginx start
  - sh pumactrl.sh start
  - RAILS_ENV="" rake assets:precompile

* ...
