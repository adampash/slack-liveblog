require 'rails_helper'

RSpec.describe MessagesController, type: :controller do

  describe "GET #embed" do
    it "returns http success" do
      get :embed
      expect(response).to have_http_status(:success)
    end
  end

end
