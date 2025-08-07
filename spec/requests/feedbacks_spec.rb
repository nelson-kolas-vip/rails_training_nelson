require 'rails_helper'

RSpec.describe FeedbacksController, type: :request do
  let!(:staff_user) { FactoryBot.create(:staff_user) }
  let!(:customer_user) { FactoryBot.create(:customer_user) }
  let!(:restaurant) { FactoryBot.create(:restaurant, user: staff_user) }
  let!(:general_feedback) { FactoryBot.create(:feedback, restaurant: nil, user: customer_user) }
  let!(:restaurant_feedback) { FactoryBot.create(:feedback, restaurant: restaurant, user: customer_user) }

  describe "GET #index" do
    context "when authenticated" do
      before { sign_in customer_user, scope: :user }

      it "renders a successful response and shows all feedbacks when no restaurant_id is present" do
        get feedbacks_path
        expect(response).to be_successful
        expect(response.body).to include("Customer Feedback")
        expect(response.body).to include(general_feedback.comment)
        expect(response.body).to include(restaurant_feedback.comment)
      end
    end

    context "when not authenticated" do
      it "redirects to the sign in page" do
        get feedbacks_path
        expect(response)
      end
    end
  end

  describe "GET #new" do
    context "when authenticated as a customer" do
      before { sign_in customer_user, scope: :user }

      it "renders a successful response for general feedback" do
        get new_feedback_path
        expect(response).to be_successful
        expect(response.body).to include("Leave Feedback")
        expect(response.body).to include(customer_user.first_name)
      end

      it "renders a successful response for restaurant-specific feedback" do
        get new_restaurant_feedback_path(restaurant)
        expect(response)
        expect(response.body).to include("#{restaurant.name}")
        expect(response.body).to include(customer_user.first_name)
      end
    end

    context "when not authenticated" do
      it "redirects to the sign in page" do
        get new_feedback_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #create" do
    before { sign_in customer_user, scope: :user }
    let(:valid_params) do
      {
        rating: 4,
        comment: "This is a great comment about the restaurant.",
        customer_name: "Test Customer",
        current_user_url: "http://example.com/restaurants/1"
      }
    end

    context "with valid parameters for general feedback" do
      it "creates a new general feedback (not associated with a restaurant)" do
        expect do
          post feedbacks_path, params: { feedback: valid_params.except(:restaurant_id) }
        end.to change(Feedback, :count).by(1)
        expect(Feedback.last.restaurant).to be_nil
        expect(Feedback.last.user).to eq(customer_user)
      end

      it "redirects to root with a notice for general feedback" do
        post feedbacks_path
        expect(response)
        expect(response.body).to include("Feedback submitted successfully!")
      end
    end

    context "with invalid parameters" do
      it "does not create feedback if rating is missing" do
        invalid_params = valid_params.merge(rating: nil)
        expect do
          post restaurant_feedbacks_path(restaurant), params: { feedback: invalid_params }
        end.to_not change(Feedback, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Failed to submit feedback")
      end

      it "does not create feedback if comment is too short" do
        invalid_params = valid_params.merge(comment: "short")
        expect do
          post restaurant_feedbacks_path(restaurant), params: { feedback: invalid_params }
        end.to_not change(Feedback, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Failed to submit feedback")
      end
    end

    context "when not authenticated" do
      it "does not create feedback and redirects to sign in" do
        expect do
          post restaurant_feedbacks_path(restaurant), params: { feedback: valid_params }
        end
      end
    end
  end
end
