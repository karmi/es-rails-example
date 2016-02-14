class QuestionsController < ApplicationController
  def index
    @questions = Question.page params[:page]
  end

  def show
    @question = Question.find(params[:id])
  end

  def search
    @questions = Searchable.search(query: params[:q], tags: params[:t], months: params[:m]).page(params[:page]).results
    render action: "index"
  end
end
