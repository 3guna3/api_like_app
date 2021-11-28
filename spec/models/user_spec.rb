require "rails_helper"

RSpec.describe User, type: :model do
  context "ユーザーが削除されたとき" do
    subject { user.destroy }
    let(:user) { create(:user) }

    context "投稿が存在するのであれば" do
      before { create_list(:post, 5, user: user) }

      it "ユーザーの投稿が全て削除される" do
        expect { subject }.to change { user.posts.count }.from(5).to(0)
      end
    end
  end
end
