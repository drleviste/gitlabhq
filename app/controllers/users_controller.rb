class UsersController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]
  layout :determine_layout

  def show
    @user = User.find_by_username!(params[:username])
    @projects = @user.authorized_projects.accessible_to(current_user)

    if !current_user && @projects.empty?
      return authenticate_user!
    end

    @groups = @user.groups.accessible_to(current_user)
    @events = @user.recent_events.where(project_id: @projects.pluck(:id)).limit(20)
    @title = @user.name

    user_projects = @user.authorized_projects.accessible_to(@user)
    @user_projects = user_projects.map(&:repository)

    @timestamps = Gitlab::Calendar.create_timestamp(@user_projects, @user, false)
    @time_copy = Gitlab::Calendar.create_time_copy(@timestamps)
    @timestart_year = Gitlab::Calendar.timestart_year(@timestamps)
    @timestart_month = Gitlab::Calendar.timestart_month(@timestamps)
    @last_commit_date = Gitlab::Calendar.last_commit_date(@timestamps)
  end

  def activities
    @user = User.find_by_username!(params[:username])
    user_projects = @user.authorized_projects.accessible_to(@user)
    @user_projects = user_projects.map(&:repository)

    user_activities = Gitlab::Calendar.create_timestamp(@user_projects, @user, true)
    user_activities = Gitlab::Calendar.commit_activity_match(user_activities, params[:date])
    render json: user_activities.to_json
  end

  def determine_layout
    if current_user
      'navless'
    else
      'public_users'
    end
  end
end
