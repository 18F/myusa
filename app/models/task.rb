class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  has_many :task_items, :dependent => :destroy

  validates_presence_of :app_id, :user_id, :name

  # attr_accessible :name, :completed_at, :task_items_attributes, :as => [:default, :admin]
  # attr_accessible :user, :user_id, :app, :app_id, :as => :admin
  accepts_nested_attributes_for :task_items
  
  scope :uncompleted, where('ISNULL(completed_at)')
  
  def self.newest_first
    order('created_at DESC', 'id DESC')
  end

  def complete!
    self.task_items.each{|task_item| task_item.complete!}
    self.update_attributes(:completed_at => Time.now) 
  end
  
  def completed?
    self.completed_at.nil? ? false : true
  end
end
