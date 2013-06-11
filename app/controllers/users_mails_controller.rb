class UsersMailsController < ApplicationController
  # GET /users_mails
  # GET /users_mails.json
  def index
    @users_mails = UsersMail.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users_mails }
    end
  end

  # GET /users_mails/1
  # GET /users_mails/1.json
  def show
    @users_mail = UsersMail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @users_mail }
    end
  end

  # GET /users_mails/new
  # GET /users_mails/new.json
  def new
    @users_mail = UsersMail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @users_mail }
    end
  end

  # GET /users_mails/1/edit
  def edit
    @users_mail = UsersMail.find(params[:id])
		rescue
			redirect_to new_users_mail_path(:user_id => params[:id])
  end

  # POST /users_mails
  # POST /users_mails.json
  def create
    @users_mail = UsersMail.new(params[:users_mail])

    respond_to do |format|
      if @users_mail.save
        format.html { redirect_to @users_mail, notice: 'Users mail was successfully created.' }
        format.json { render json: @users_mail, status: :created, location: @users_mail }
      else
        format.html { render action: "new" }
        format.json { render json: @users_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users_mails/1
  # PUT /users_mails/1.json
  def update
    @users_mail = UsersMail.find(params[:id])

    respond_to do |format|
      if @users_mail.update_attributes(params[:users_mail])
        format.html { redirect_to @users_mail, notice: 'Users mail was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @users_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users_mails/1
  # DELETE /users_mails/1.json
  def destroy
    @users_mail = UsersMail.find(params[:id])
    @users_mail.destroy

    respond_to do |format|
      format.html { redirect_to users_mails_url }
      format.json { head :ok }
    end
  end
end
