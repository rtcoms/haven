class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:create_demo_user]
  before_action :verify_admin, except: [:create_demo_user]

  def index
    @users = User.order(email: :asc)
  end
  
  def new
    @user = User.new
  end

  def create_demo_user
    @email = params[:email]
    @password = Devise.friendly_token.first(20)
    admin = 2 # Publisher
    @user = User.create!(
      email: @email,
      name: "",
      admin: admin,
      password: @password,
      basic_auth_username: Devise.friendly_token.first(10),
      basic_auth_password: Devise.friendly_token.first(10)
    )
    render :show_demo_user
  end

  def create
    @password = Devise.friendly_token.first(20)
    admin = 0 # Subscriber
    admin = 1 if params[:user][:role] == "admin"
    admin = 2 if params[:user][:role] == "publisher"
    email = params[:user][:email]
    name = params[:user][:name]
    @user = User.create!( 
      email: email,
      name: name,
      admin: admin,
      password: @password,
      basic_auth_username: Devise.friendly_token.first(10),
      basic_auth_password: Devise.friendly_token.first(10)
    )
    @verb = "created"
    login_link = LoginLink.generate(@user)
    @token = login_link.token
    render :show
  end

  def resetpassword
    @password = Devise.friendly_token.first(20)
    @user = User.find(params[:id])
    @user.update_attributes(password: @password)
    @verb = "updated"
    @user.login_links.each {|ll| ll.destroy} ## delete old links
    login_link = LoginLink.generate(@user)
    @token = login_link.token
    render :show
  end

  def toggleadmin
    @user = User.find(params[:id])
    @user.admin = (@user.admin + 1) % 3 #toggle between 1 (Admin), 2 (Subscriber)  and 0 (Subscriber)
    @user.save
    redirect_to users_path
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end


end
