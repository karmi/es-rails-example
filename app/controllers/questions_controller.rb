class QuestionsController < ApplicationController
  def index
    @questions = Question.page params[:page]
  end

  def show
    @question = Question.find(params[:id])
  end
end
