class FriendshipsController < ApplicationController
  before_filter :authenticate_user!
  def index
    
    @users=User.friends_wich_accepted(current_user.id).paginate(:page => params[:page])


    respond_to do |format|
      format.html 
   
    end
  end

  def incoming
    @users = current_user.inverse_friends.paginate(:page => params[:page])

    respond_to do |format|
      format.html
   
    end
  end
  def outgoing
    @users = current_user.unauthorized_friends.paginate(:page => params[:page])

    respond_to do |format|
      format.html
     
    end
  end
 
  def show
    @friendship = Friendship.find(params[:id])

    respond_to do |format|
      format.html 
     
    end
  end

  
  def new
    redirect_to users_url
  
  end

  
  def edit
    @friendship = Friendship.find(params[:id])
  end

  
  def create
    # Rails.logger.info "__________________params_____________________#{params.inspect}"  
     @friendship = current_user.friendships.create!(:friend_id=>params[:format])
     redirect_to friendships_url

  end

  

  def update
   
    @friendship = Friendship.find_by_user_id_and_friend_id(params[:id],current_user.id)
   
    respond_to do |format|
      if @friendship.update_attributes(:authorized=>true)
        format.html { redirect_to incoming_requests_path, notice: 'Friendship was successfully authorized.' }
      
      else
        format.html { redirect_to incoming_requests_path }
       
      end
    end
  end

  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy


    if @friendship = Friendship.find_by_user_id_and_friend_id(current_user.id, params[:id])
    @friendship.destroy
  else
    if @friendship = Friendship.find_by_user_id_and_friend_id(params[:id], current_user.id)
    @friendship.destroy
    end
  end

    respond_to do |format|
     format.html { redirect_to friendships_url }
    
    end
  end
end
