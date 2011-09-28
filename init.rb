require 'redmine'
require File.dirname(__FILE__) + '/lib/issues_controller_patch.rb'

require 'dispatcher'
Dispatcher.to_prepare :redmine_spent_time_required do
  require_dependency 'issues_controller'
  IssuesController.send(:include, RedmineSpentTimeRequired::Patches::IssuesControllerPatch)
end

Redmine::Plugin.register :redmine_spent_time_required do
  name 'Redmine Spent Time Required'
  author 'Max Prokopiev'
  description 'Plugin to require adding spent time'
  version '0.0.1'
  url 'http://trs.io/'
  author_url 'http://github.com/juggler'

  settings(:default => {
             'statuses' => '3 5'
           }, :partial => 'settings/spent_time_settings')

end
