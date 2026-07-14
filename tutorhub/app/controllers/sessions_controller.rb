# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if user_signed_in?
  end

  def create
    user = User.authenticate(params[:email], params[:password])

    if user
      login_as(user)
      flash[:notice] = 'Signed in.'
      redirect_to(params[:return_to].presence || dashboard_path)
    else
      flash.now[:alert] = 'Email or password is incorrect.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    flash[:notice] = 'Signed out.'
    redirect_to root_path
  end
end
