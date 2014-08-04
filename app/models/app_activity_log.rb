class AppActivityLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  attr_accessible :user, :app, :controller, :action, :description

  validates_presence_of :controller, :action
 
  default_scope order('created_at DESC', 'id DESC').limit(10)
  scope :last_n_days, lambda { |days| where('updated < ?', days) }
  
  def to_s
    "#{self.app.name.titleize} #{humanize_log_item(self)} at #{self.created_at.strftime('%H:%M %p')}"
  end
  
  protected
  
  def humanize_log_item(item)
    map = {
      profiles: {
        show: 'viewed your profile'
      },
      notifications: {
        create: 'pushed a notification'
      },
      oauth: {
        authorize: 'authorized your account'
      },
      tasks: {
        create: 'created tasks',
        index: 'viewed your task list',
        show: 'viewed a task'
      }
    }

    begin
      return map[item.controller.to_sym][item.action.to_sym]
    rescue
      return ['accessed', [item.controller, item.action].join('#')].join(' ')
    end
  end
  
end
