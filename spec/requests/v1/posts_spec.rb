require "rails_helper"

RSpec.describe "V1::Posts", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }
  let(:user) { create(:user) }

  describe "GET #index" do
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

  describe "GET #show" do
    subject { get(v1_post_path(post_id), headers: headers) }
    let(:post) { create(:post, user_id: current_user.id) }
    let(:post_id) { post.id }

    context "トークン認証情報がない場合" do
      subject { get(v1_post_path(post_id)) }
      it "エラーが発生する" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "指定したidの投稿が存在する場合" do
      it "指定したidの投稿を取得できること" do
        subject
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json["title"]).to eq post.title
        expect(json["content"]).to eq post.content
      end
    end

    context "指定したidの投稿が存在しない場合" do
      let(:post_id) { 0 }
      it "エラーが発生する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #create" do
    subject { post(v1_posts_path, params: post_params, headers: headers) }
    let(:post_params) { { post: attributes_for(:post, user_id: current_user.id) } }

    context "トークン認証情報がない場合" do
      subject { post(v1_posts_path, params: post_params) }
      it "エラーが発生する", type: :do do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "パラメータが正常な時" do
      it "データが保存されること" do
        expect { subject }.to change { Post.count }.by(1)
        expect(response).to have_http_status(:ok)
      end
    end

    context "パラメータが異常な時" do
      let(:post_params) { { post: attributes_for(:post, :invalid, user_id: current_user.id) } }
      it "データが保存されないこと" do
        expect { subject }.not_to change { Post.count }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["title"]).to include "を入力してください"
        expect(json["content"]).to include "を入力してください"
      end
    end
  end

  describe "PATCH #update" do
    subject { patch(v1_post_path(post_id), params: post_params, headers: headers) }
    let(:post) { create(:post, user_id: current_user.id) }
    let(:post_id) { post.id }

    context "トークン認証情報がない場合" do
      subject { patch(v1_post_path(post_id), params: post_params) }
      let(:post_params) { { post: attributes_for(:post, user_id: current_user.id) } }
      it "エラーが発生する" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "パラーメータが正常な時 && 本人投稿の場合" do
      let(:post_params) { { post: attributes_for(:post, user_id: current_user.id) } }
      it "投稿が更新されること" do
        new_post = post_params[:post]
        expect { subject }
          .to change { post.reload.title }
          .from(post.title).to(new_post[:title])
          .and change { post.reload.content }
          .from(post.content).to(new_post[:content])
        expect(response).to have_http_status(:ok)
      end
    end

    context "パラーメータが正常な時 && 本人以外の投稿の場合" do
      let(:post_params) { { post: attributes_for(:post, user_id: user.id) } }
      let(:other_post) { create(:post, user_id: user.id) }
      let(:post_id) { other_post.id }
      it "エラーが発生する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "パラメータが異常な時" do
      let(:post_params) { { post: attributes_for(:post, :invalid, user_id: current_user.id0) } }
      it "パラメータが更新されないこと" do
        expect { subject }.not_to change { post.reload.title }
        expect { subject }.not_to change { post.reload.content }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["title"]).to include "を入力��てください"
        expect(json["content"]).to include "を入力してください"
      end
    end
  end

  describe "DELETE #destroy" do
    subject { delete(v1_post_path(post_id), headers: headers) }

    context "本人の投稿の場合" do
      let!(:post) { create(:post, user_id: current_user.id) }
      it "投稿が削除されること" do
        expect { subject }.to change { Post.count }.by(0)
        expect(response).to have_http_status(:ok)
      end
    end

    context "本人以外の投稿の場合" do
      let!(:post) { create(:post, user_id: user.id) }
      it "エラーが発生する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "トークン認証がない場合" do
      subject { delete(v1_post_path(post.id)) }
      let!(:post) { create(:post, user_id: current_user.id) }
      it "エラーが発生する" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
