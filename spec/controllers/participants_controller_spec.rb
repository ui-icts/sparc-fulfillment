require 'rails_helper'

RSpec.describe ParticipantsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @participant = create(:participant, protocol_id: @protocol.id)
  end

  describe "GET #index" do
    it "should get participants" do
      get :index, {
        protocol_id: @protocol.id,
        format: :json
      }
      expect(assigns(:participants)).to eq([@participant])
    end
  end

  describe "GET #new" do
    it "should instantiate a new participant" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        format: :js
      }
      expect(assigns(:participant)).to be_a_new(Participant)
    end
  end

  describe "POST #create" do
    it "should create a new participant" do
      expect{
        post :create, {
          protocol_id: @protocol.id,
          participant: attributes_for(:participant),
          format: :js
        }
      }.to change(Participant, :count).by(1)
    end
  end

  describe "GET #edit" do
    it "should select an instantiated participant" do
      xhr :get, :edit, {
        protocol_id: @protocol.id,
        id: @participant.id,
        format: :js
      }
      expect(assigns(:participant)).to eq(@participant)
    end
  end

  describe "PUT #update" do
    it "should update a participant" do
      put :update, {
        protocol_id: @protocol.id,
        id: @participant.id,
        participant: attributes_for(:participant, first_name: 'Chick'),
        format: :js
      }
      @participant.reload
      expect(@participant.first_name).to eq 'Chick'
    end
  end

  describe "DELETE #destroy" do
    it "should delete a participant" do
      expect{
        delete :destroy, {
          protocol_id: @protocol.id,
          id: @participant.id,
          format: :js
        }
      }.to change(Participant, :count).by(-1)
    end
  end

  describe "GET #edit_arm" do
    it "should find the participant's arm" do
      @arm = create(:arm, protocol_id: @protocol.id)
      @participant.arm = @arm
      @participant.save
      xhr :get, :edit_arm, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        id: @arm.id,
        format: :js
      }
      expect(assigns(:arm)).to eq(@arm)
      expect(assigns(:path)).to eq("/protocols/#{@protocol.id}/participants/#{@participant.id}/change_arm/#{@arm.id}")
    end

    it "should not find the participant's arm" do
      xhr :get, :edit_arm, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        format: :js
      }
      expect(assigns(:arm)).to be_a_new(Arm)
      expect(assigns(:path)).to eq("/protocols/#{@protocol.id}/participants/#{@participant.id}/change_arm")
    end
  end

  describe "PUT #update_arm" do
    it "should change a participant's arm" do
      @arm = create(:arm, protocol_id: @protocol.id)
      put :update_arm, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        arm: @arm,
        format: :js
      }
      @participant.reload
      expect(@participant.arm.id).to eq @arm.id
    end
  end
end