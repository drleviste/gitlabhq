module UsersHelper
  def create_timestamp(user_project)
    timestamps = {}
    user_project.each do |raw_repository|
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
end
