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
    repositories = user_projects.map(&:repository)

    if repositories.empty?
      @time_copy = DateTime.now.to_date
      @timestamps = {}
    end

    @timestamps = create_timestamp(repositories)
    create_time_copy(@timestamps)
    @timestamps = @timestamps.to_json
  end

  def create_timestamp(repositories)
    timestamps = {}
    repositories.each do |raw_repository|
      if raw_repository.exists?
        commits_log = commits_log_by_commit_date(raw_repository.graph_log)
        commits_log.each do |k, v|
          hash = { "#{k}" => v.count }
          timestamps.merge!(hash)
        end
      end
    end
    timestamps
  end

  def create_time_copy(timestamps)
    @time_copy = if timestamps.empty?
                   DateTime.now.to_date
                 else
                   Time.at(timestamps.first.first.to_i).to_date
                 end
  end

  def commits_log_by_commit_date(graph_log)
    graph_log.select { |u_email| u_email[:author_email] == @user.email }.
      map { |graph_log| Date.parse(graph_log[:date]).to_time.to_i }.
      group_by { |commit_date| commit_date }
  end

  def determine_layout
    if current_user
      'navless'
    else
      'public_users'
    end
  end
end
