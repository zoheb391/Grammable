require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  
  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do
      gram = FactoryGirl.create(:gram)

      get :show, id: gram.id
      expect(response).to have_http_status(:success)
    end
    
    it "should return a 404 error if the gram is not found" do
      get :show, id: 'tacos'
      expect(response).to have_http_status(:not_found)
    end
  end


  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require that a user is signed in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the page" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    
    it "should require a user to be logged in" do
      post :create , gram: {message: "hello"}
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in the database" do
      user = FactoryGirl.create(:user)
      sign_in user
      
      post :create, gram: {
        message: 'hello!',
        picture: fixture_file_upload("/picture.jpg", 'image/jpg')
      }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly deal with validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      gram_count = Gram.count
      post :create, gram: {message: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(gram_count).to eq Gram.count
    end
  end

  describe "grams#edit action" do
    it "shouldn't let a user who did not create the gram edit a gram" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      get :edit, id: gram.id
      expect(response).to have_http_status(:forbidden)      
    end

    it "shouldn't let unauthenticated users edit a gram" do
      gram = FactoryGirl.create(:gram)
      get :edit, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user

      get :edit, id: gram.id
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error message if the gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :edit, id: 'SWAG'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do
    it "shouldn't let users who didn't create the gram update it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, id: gram.id, gram: { message: "Hello" }
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users create a gram" do
      gram = FactoryGirl.create(:gram)
      patch :update, id: gram.id, gram: { message: "Hello" }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully update the gram" do
      gram = FactoryGirl.create(:gram, message: 'initial Value')
      sign_in gram.user
      
      patch :update, id: gram.id, gram: {message: 'changed'}
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq "changed"
    end
    
    it "should show 404 if gram not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, id: "YOLOSWAG", gram: {message: 'Changed'}
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status of unprocessable_entity" do
      gram = FactoryGirl.create(:gram, message: "initial Value")
      sign_in gram.user

      patch :update, id: gram.id, gram: { message: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq "initial Value"
    end
   end

  describe "grams#destroy action" do
    it "shouldn't allow users who didn't create the gram to destroy it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users destroy a gram" do
      gram = FactoryGirl.create(:gram)
      delete :destroy, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow a user to destroy grams" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user

      delete :destroy, id: gram.id
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end

    it "should return a 404 message if we cannot find a gram with the id that is specified" do
      user = FactoryGirl.create(:user)
      sign_in user

      delete :destroy, id: 'spaceduck'
      expect(response).to have_http_status(:not_found)
    end
  end

end
