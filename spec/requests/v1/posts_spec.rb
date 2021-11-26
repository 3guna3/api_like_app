require "rails_helper"

RSpec.describe "V1::Posts", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }
  let(:user) { create(:user) }

  describe "GET /index" do
    subject { get(v1_post_path, headers: headers) }

    context "トークン認証がない場合" do
      subject { get(v1_post_path) }
      let!(:post) { create(:post, user_id: current_user.id) }
      it "エラーが発生する" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end

    before { create_list(:post, 3, user_id: current_user.id) }
    context "ユーザーの投稿が存在する時" do
      it "投稿一覧を取得できること" do
        subject
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq 3
        expect(json[0].keys).to eq %w[id title content]
        expect(json[0]["id"]).to eq Post.first.id
        expect(json[0]["title"]).to eq Post.first.title
        expect(json[0]["content"]).to eq Post.first.content
      end
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/v1/posts/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/v1/posts/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/v1/posts/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/v1/posts/destroy"
      expect(response).to have_http_status(:success)
    end
  end
end
