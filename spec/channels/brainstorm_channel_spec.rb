require 'rails_helper'

RSpec.describe BrainstormChannel, type: :channel do
  let(:owner) { create(:user) }
  let(:member_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: owner) }
  let!(:brainstorm_member) { create(:brainstorm_member, brainstorm: brainstorm, user: member_user, role: "editor") }

  before do
    Rails.cache.clear
  end

  describe "#subscribed" do
    context "オーナーの場合" do
      before do
        stub_connection current_user: owner
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
      end

      it "正常にサブスクライブされる" do
        subscribe(brainstorm_id: brainstorm.id)
        expect(subscription).to be_confirmed
      end

      it "brainstormのストリームに接続される" do
        subscribe(brainstorm_id: brainstorm.id)
        expect(subscription).to have_stream_for(brainstorm)
      end

      it "オンラインメンバーにキャッシュされる" do
        subscribe(brainstorm_id: brainstorm.id)
        online_key = "brainstorm_#{brainstorm.id}_online"
        online_members = Rails.cache.read(online_key)
        expect(online_members).to include(a_hash_including(id: owner.id))
      end

      it "member_connectedイベントをbroadcastする" do
        expect {
          subscribe(brainstorm_id: brainstorm.id)
        }.to have_broadcasted_to(brainstorm).from_channel(BrainstormChannel).with(
          a_hash_including("event" => "member_connected", "user_id" => owner.id)
        )
      end
    end

    context "メンバーの場合" do
      before { stub_connection current_user: member_user }

      it "正常にサブスクライブされる" do
        subscribe(brainstorm_id: brainstorm.id)
        expect(subscription).to be_confirmed
      end

      it "brainstormのストリームに接続される" do
        subscribe(brainstorm_id: brainstorm.id)
        expect(subscription).to have_stream_for(brainstorm)
      end
    end

    context "非メンバーの場合" do
      before { stub_connection current_user: other_user }

      it "rejectされる" do
        subscribe(brainstorm_id: brainstorm.id)
        expect(subscription).to be_rejected
      end
    end

    context "存在しないbrainstorm_idの場合" do
      before { stub_connection current_user: owner }

      it "rejectされる" do
        subscribe(brainstorm_id: 99999)
        expect(subscription).to be_rejected
      end
    end

    context "同じユーザーが二重接続した場合" do
      before do
        stub_connection current_user: owner
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
      end

      it "オンラインメンバーに重複して追加されない" do
        subscribe(brainstorm_id: brainstorm.id)
        unsubscribe
        subscribe(brainstorm_id: brainstorm.id)
        online_key = "brainstorm_#{brainstorm.id}_online"
        online_members = Rails.cache.read(online_key)
        expect(online_members.count { |m| m[:id] == owner.id }).to eq(1)
      end
    end
  end

  describe "#unsubscribed" do
    context "オーナーが切断した場合" do
      before do
        stub_connection current_user: owner
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
        subscribe(brainstorm_id: brainstorm.id)
      end

      it "オンラインメンバーから削除される" do
        unsubscribe
        online_key = "brainstorm_#{brainstorm.id}_online"
        online_members = Rails.cache.read(online_key)
        expect(online_members).not_to include(a_hash_including(id: owner.id))
      end

      it "member_disconnectedイベントをbroadcastする" do
        expect {
          unsubscribe
        }.to have_broadcasted_to(brainstorm).from_channel(BrainstormChannel).with(
          a_hash_including("event" => "member_disconnected", "user_id" => owner.id)
        )
      end
    end
  end
end
