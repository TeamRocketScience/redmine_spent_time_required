require 'redmine'
require File.dirname(__FILE__) + '/lib/issues_controller_patch.rb'

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'issues_controller'
    IssuesController.send(:include, RedmineSpentTimeRequired::Patches::IssuesControllerPatch)
  end
else
  require 'dispatcher'
  Dispatcher.to_prepare do
    require_dependency 'issues_controller'
    IssuesController.send(:include, RedmineSpentTimeRequired::Patches::IssuesControllerPatch)
  end
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
