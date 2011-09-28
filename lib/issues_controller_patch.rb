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
          current_status = params[:issue][:status_id]
          if ((params[:time_entry][:hours] == "") && (allowed_statuses.member?(current_status.to_s)))
            flash[:error] = "Spent time required"
            find_issue
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
