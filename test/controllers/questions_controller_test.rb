require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_equal 2, assigns(:questions).size
  end

  test "should get detail" do
    get :show, id: Question.first.id
    assert_response :success
  end

  test "should get search" do
    get :search, q: 'one'
    assert_response :success
    assert_equal 1, assigns(:questions).size
  end
end
