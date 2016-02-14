require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get detail" do
    get :show, id: Question.first.id
    assert_response :success
  end
end
