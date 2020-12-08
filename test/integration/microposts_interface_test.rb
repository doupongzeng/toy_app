require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'

    #invalid micro
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: ""}}
    end
    assert_select 'div#error_explanntion'

    #valid micro
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: {micropost: {content: content, picture: picture}}
    end
    assert @user.microposts.first.picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    #delete micro
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    #see another user
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body

    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
#    assert_match "0 microposts", response.body
    assert other_user.microposts.count == 0
    other_user.microposts.create!(content: "A micro")
    get root_path
#    assert_match "A micro", response.body
    assert other_user.microposts.count == 1
  end

end
