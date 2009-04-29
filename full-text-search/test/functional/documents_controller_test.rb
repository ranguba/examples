require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show document" do
    get :show, :id => documents(:groonga).to_param
    assert_response :success
  end
end
