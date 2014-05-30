puts "===================" * 100
module Gitlab
  class Calendar
    def self.create_timestamp(user_projects, user)
      timestamps = {}
      user_projects.each do |raw_repository|
        if raw_repository.exists?
          commits_log = raw_repository.commits_log_of_user_by_date(user)
          commits_log.each do |timestamp_date, commits|
            hash = { "#{timestamp_date}" => commits }
            if timestamps.has_key?("#{timestamp_date}")
              timestamps.merge!(hash) { |timestamp_date, commits, new_commits|
                                        commits = commits.to_i + new_commits }
            else
              timestamps.merge!(hash)
            end
          end
        end
      end
      timestamps
    end

    def self.create_timestamps_by_project(user_projects, user)
    projects = {}
      project_commit = {}
      timestamps_copy = {}

      user_projects.each do |raw_repository|
        if raw_repository.exists?
          commits_log = raw_repository.commits_log_of_user_by_date(user)
          commits_log.each do |timestamp_date, commits|
            if timestamps_copy.has_key?("#{timestamp_date}")
              timestamps_copy["#{timestamp_date}"].
                merge!(raw_repository.path_with_namespace => commits)
            else
              hash = { "#{timestamp_date}" => { raw_repository.path_with_namespace => commits }
                                  }
              timestamps_copy.merge!(hash)
            end
          end
          project_commit = project_commits(timestamps_copy,
                                           raw_repository.path_with_namespace)
          projects.merge!(timestamps_copy)
        end
      end
      projects
    end

    def self.project_commits(timestamps, repository_name)
      timestamps.each do |date|
        hash = { "#{timestamps}" => repository_name }
      end
    end

    def self.create_time_copy(timestamps)
      #timestamps = create_timestamp(user_projects)
      time_copy = if timestamps.empty?
                    DateTime.now.to_date
                  else
                    Time.at(timestamps.keys.first.to_i).to_date
                  end
      time_copy
      
    end

    def self.timestart_year(timestamps)
      create_time_copy(timestamps).year - 1
    end

    def self.timestart_month(timestamps)
      create_time_copy(timestamps).month
    end

    def self.last_commit_date(timestamps)
      create_time_copy(timestamps).to_formatted_s(:long).to_s
    end

    # def self.commits_log_by_commit_date(graph_log, user)
    #   graph_log.select { |u_email| u_email[:author_email] == user.email }.
    #     map { |graph_log| Date.parse(graph_log[:date]).to_time.to_i }.
    #     group_by { |commit_date| commit_date }.
    #     inject({}) {|hash, (k,v)| hash[k]=v.count; hash}
    # end

    def self.commit_activity_match(user_activities, date)
      user_activities.select { |x| Time.at(x.to_i) == Time.parse(date) }
    end
  end
end