require 'test_helper'

class LaporanCabangControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
