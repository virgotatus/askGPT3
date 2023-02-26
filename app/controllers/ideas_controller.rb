class IdeasController < ApplicationController
  def index
    @idea = Idea.new
  end
  def create
  end
  def ask_ai
    puts "asky"
  end

end
