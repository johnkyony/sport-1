class EventsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @title = "My events"
    @titlesearch
    @events = current_user.events.paginate(page: params[:page])
  end

  def master
    @title="Events that i create"
    @events = current_user.master_events.paginate(page: params[:page])
  end

  def joined
    @title="Joined events"
    users_events = current_user.users_events.where(role: false)
    events = []
    users_events.each do |user_event|
      events << user_event.event
    end
    events.compact!
    @events = events.paginate(page: params[:page])
  end

  def all
    @title = "All events"
    @events = Event.paginate(page: params[:page])
  end

  def show
    @event = Event.find(params[:id])
    @width = 500
    @latitude = @event.latitude
    @longitude = @event.longitude
    @zoom = 12
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.new(params[:event].merge(members: 1))
    if @event.valid?
      @event = current_user.events.create(params[:event].merge(members: 1))
      user_event = current_user.users_events.where(event_id: @event.id).first
      user_event.update_attributes(role: true) if user_event.present?
      flash[:notice] = 'Event was successfully created.'
      redirect_to event_url(@event)
    else
      render "new"
    end
  end

  def update
    @event = Event.find(params[:id])
    
    if @event.update_attributes(params[:event])
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render "edit"
    end
  end

  def join
    @event = Event.find(params[:event_id])
    if current_user.join_event!(@event)
      flash.now[:success] = "You could not join to this event"
    else
      flash.now[:error] = "You have joined to this event"
    end
    
    redirect_to events_path
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to events_url
  end

  def search
    if @event = Event.find_by_title(params[:Search][:title123])
      redirect_to @event
    else
      redirect_to events_path
    end
  end

  def index_search
    @events = Event.order(:title).where("title like ?", "%#{params[:term]}%")
    render json: @events.map(&:title)
  end
end
