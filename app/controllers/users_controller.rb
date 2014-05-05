class UsersController < ApplicationController
  include UsersHelper
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
    user_project = user_projects.map(&:repository)

    @timestamps = create_timestamp(user_project)
    create_time_copy(@timestamps)
    @timestamps = @timestamps.to_json
  end

  def determine_layout
    if current_user
      'navless'
    else
      'public_users'
    end
  end
end
