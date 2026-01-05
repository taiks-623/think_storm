require 'rails_helper'

RSpec.describe "Brainstorms", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/brainstorms/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/brainstorms/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/brainstorms/show"
      expect(response).to have_http_status(:success)
    end
  end

end
