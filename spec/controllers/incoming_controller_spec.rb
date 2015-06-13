require 'rails_helper'

RSpec.describe IncomingController, type: :controller do

  describe "GET #handle" do
    it "returns http success" do
      get :handle
      expect(response).to have_http_status(:success)
    end
  end

end
