class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :birth_date, :description, :email, :first_name,
    :last_name,:email, :password, :password_confirmation, :remember_me

  has_many :microposts, :dependent => :destroy

  has_many :users_events, :dependent => :destroy
  has_many :events, :through => :users_events
  has_many :master_events, :through => :users_events, :source => :event, :conditions => [ "role = ?", true]

  has_many :messages, :foreign_key => "sender_id", :dependent => :destroy
  has_many :reverse_messages, :class_name => "Message", :foreign_key => "receiver_id", :dependent => :destroy

  has_many :receivers, :through => :messages, :source => :receiver
  has_many :senders, :through => :reverse_messages, :source => :sender

  has_many :friendships, :dependent => :destroy
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user, :conditions => [ "authorized = ?", false ]
  
  has_many :my_authorized_friends, :through => :friendships, :source => :friend, :conditions => [ "authorized = ?", true ]
  has_many :inverse_authorized_friends, :through => :inverse_friendships, :source => :user, :conditions => [ "authorized = ?", true ]
  has_many :unauthorized_friends, :through => :friendships, :source => :friend, :conditions => [ "authorized = ?", false ]

  scope :friends_wich_accepted,  lambda {
    |my_id|   User.find(my_id).my_authorized_friends + User.find(my_id).inverse_authorized_friends }
  
  
  validates_date :birth_date, :before => lambda { 18.years.ago },
    :before_message => "must be at least 18 years old"

  def can_add_to_friends?(friend)
    Friendship.my_friends(id, friend.id).present? || (id == friend.id) ? false : true
  end

  def join_event?(event)
    if UsersEvent.find_by_event_id_and_user_id(event.id, id)
      return false
    else
      UsersEvent.create(:event_id => event.id, :user_id => id)
      event.update_attributes(members: @event.members + 1)
      return true
    end
  end

  def all_chats_with_user
    group_messages = Message.all_messages_with_user(id).group("sender_id", "receiver_id");
    counted = group_messages.count
    messages = []
    group_messages.each_with_index do | message, i |
    messages[i] = message
    j = 0  
    exit = 0
      while  (j < i)&&(exit == 0) do  
       if (message.sender_id == group_messages[j].receiver_id)&&(message.receiver_id== group_messages[j].sender_id)
        messages[j][:count] = messages[j][:count] + counted[[message.sender_id, message.receiver_id]]
        messages = messages - [messages[i]]
        exit = 1
       end
       j += 1
      end
      if exit == 0
      messages[i][:count] = counted[[message.sender_id, message.receiver_id]]
      end
    end
    return messages.compact
  end

  def add_to_friends!(friend)
    friendships.create!(:friend => friend)
  end

  def can_join?(event)
    UsersEvent.find_by_event_id_and_user_id(event.id, id) ? false : true
  end

   def can_edit_event?(event)
    a=true
    if UsersEvent.find_by_event_id_and_user_id(event.id, id)
       (UsersEvent.find_by_event_id_and_user_id(event.id, id)[:role] == true) ? a = true : a = false
    else
      a = false
    end
    return a
   end
end



