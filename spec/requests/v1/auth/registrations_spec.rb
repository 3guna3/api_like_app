require "rails_helper"

RSpec.describe "V1::Auth::Registrations", type: :request do
  describe "Post /v1/auth" do
    subject { post(v1_user_registration_path, params: params) }

    context "パラメータが妥当な場合" do
      let(:params) { attributes_for(:user) }
      it "新規登録ができること" do
        expect { subject }.to change { User.count }.by(1)
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["data"]["email"]).to eq(User.last.email)
      end

      it "本人承認として使用されるheader情報を取得することができること" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "パラメータが不正な場合" do
      context "emailが存在しないとき" do
        let(:params) { attributes_for(:user, email: nil) }
        it "エラーが発生する" do
          expect { subject }.to change { User.count }.by(0)
          res = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(res["errors"]["email"][0]).to include "を入力してください"
        end
      end

      context "パスワードが存在しないとき" do
        let(:params) { attributes_for(:user, password: nil) }
        it "エラーが発生する" do
          expect { subject }.to change { User.count }.by(0)
          res = JSON(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(res["errors"]["password"][0]).to include "を入力してください"
        end
      end
    end
  end
end
