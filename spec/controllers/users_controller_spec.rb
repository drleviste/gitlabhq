require 'spec_helper'

describe UsersController do
  let(:user)    { create(:user, username: "eumir", name: "Eumir", email: "eumir@aelogica.com", password: "eumir1234") }
  
  before do
    sign_in(user)
  end

  describe "GET #show" do 
    render_views
    before do
      get :show, username: user.username
    end

    it "renders the show template" do
      expect(response.status).to eq(200)
      expect(response).to render_template("show")
    end

    it "renders calendar" do
      controller.prepend_view_path 'app/views/users'
      expect(response).to render_template("_calendar")
      
    end
  end
end
