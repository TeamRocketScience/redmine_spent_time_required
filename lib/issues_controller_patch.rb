module RedmineSpentTimeRequired
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :update, :check_spent_time
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def update_with_check_spent_time
          allowed_statuses = Setting.plugin_redmine_spent_time_required['statuses'].scan(/\d+/)
          need_comment = Setting.plugin_redmine_spent_time_required['need_comment']
          current_status = params[:issue][:status_id]
          if (not (allowed_statuses.member?(current_status.to_s))) or (not params.has_key? :time_entry)
            update_without_check_spent_time
            return
          end
          find_issue
          params[:time_entry][:hours].sub! ',', '.'
          spent_hours    = @issue.time_entries.map { |te| te.hours }.sum 
          entered_hours  = params[:time_entry][:hours].to_f
          if ((entered_hours + spent_hours) == 0.0)
            flash[:error] = "Spent time required"
            update_issue_from_params
            render(:action => 'edit') and return
          elsif ((entered_hours > 0.0) && (params[:time_entry][:comments] == "") && need_comment)
            flash[:error] = "Comment required"
            update_issue_from_params
            render(:action => 'edit') and return
          else
            update_without_check_spent_time
          end
        end
      end

    end
  end
end
