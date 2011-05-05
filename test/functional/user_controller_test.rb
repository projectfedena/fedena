require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class UserControllerTest < ActionController::TestCase
  fixtures :batches, :courses, :users

  setup do
    @controller = UserController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.session[:user_id] = 1
  end

  should "go to login" do
    get :login
    assert_response 200
    assert_template :login
  end

end
