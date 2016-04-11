module RedmineSpentTimeRequired
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :update,      :check_spent_time
          alias_method_chain :bulk_update, :check_spent_time
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        
        def check_spent_time(issue, allowed_statuses, need_comment)
          current_status = issue.status.id
          if params.include? :issue and params[:issue].include? :status_id
            if not allowed_statuses.member?(params[:issue][:status_id])
              return true
            end
          else
            if not allowed_statuses.member?(current_status.to_s)
              return true
            end
          end
          spent_hours    = issue.time_entries.map { |te| te.hours }.sum 
          if params.include? :time_entry
            entered_hours = params[:time_entry][:hours].to_f
          else
            entered_hours = 0
          end
          if (entered_hours + spent_hours) == 0.0
            flash[:error] = "Spent time required"
            return false
          end
          if params.include? :time_entry and params[:time_entry][:comments] == "" and need_comment
            flash[:error] = "Comment required"
            return false
          end
          return true
        end

        def update_with_check_spent_time
          if not params.has_key? :time_entry
            update_without_check_spent_time 
            return
          end
          allowed_statuses = Setting.plugin_redmine_spent_time_required['statuses'].scan(/\d+/)
          need_comment     = Setting.plugin_redmine_spent_time_required['need_comment']
          find_issue
          if !check_spent_time(@issue, allowed_statuses, need_comment)
            update_issue_from_params
            render(:action => 'edit')
          else
            update_without_check_spent_time
          end
        end

        def bulk_update_with_check_spent_time
          allowed_statuses = Setting.plugin_redmine_spent_time_required['statuses'].scan(/\d+/)
          need_comment     = Setting.plugin_redmine_spent_time_required['need_comment']
          @issues.each do |issue|
            if !check_spent_time(issue, allowed_statuses, need_comment)
              @saved_issues   = []
              @unsaved_issues = @issues
              bulk_edit
              render(:action => 'bulk_edit') 
              return
            end
          end
          bulk_update_without_check_spent_time
        end

      end

    end
  end
end
