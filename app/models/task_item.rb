class TaskItem < ActiveRecord::Base
  belongs_to :task
  
  scope :uncompleted, where('ISNULL(completed_at)')
  scope :completed, where('NOT ISNULL(completed_at)')
  
  def complete!
    self.update_attributes(:completed_at => Time.now)
  end
  
  def completed?
    self.completed_at.nil? ? false : true
  end
end
