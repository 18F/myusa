module Acl9
  module ModelExtensions
    module ClassMethods

      def acts_as_authorization_object(options = {})
        subject = options[:subject_class_name] || Acl9::config[:default_subject_class_name]
        subj_table = subject.constantize.table_name
        subj_col = subject.underscore

        role       = options[:role_class_name] || Acl9::config[:default_role_class_name]
        role_table = role.constantize.table_name

        join_table = options[:join_table_name]
        join_table ||= ActiveRecord::Base.send(:join_table_name,
          role_table, subj_table) if ActiveRecord::Base.private_methods \
          .include?('join_table_name')
        join_table ||= Acl9::config[:default_join_table_name]
        join_table ||= self.table_name_prefix \
            + [undecorated_table_name(self.to_s),
            undecorated_table_name(role)].sort.join("_") \
            + self.table_name_suffix

        has_many :accepted_roles, :as => :authorizable, :class_name => role, :dependent => :destroy

        # CP: I don't think we actually need this association, and :finder_sql is
        # no more, so I am monkeypatching to remove it.

        # has_many :"#{subj_table}", through: join_table
          # :finder_sql => proc { "SELECT DISTINCT #{subj_table}.* " +
          #                       "FROM #{subj_table} INNER JOIN #{join_table} ON #{subj_col}_id = #{subj_table}.id " +
          #                       "INNER JOIN #{role_table} ON #{role_table}.id = #{role.underscore}_id " +
          #                       "WHERE authorizable_type = '#{self.class.base_class.to_s}' AND authorizable_id = #{id} "},
          # :counter_sql => proc { "SELECT COUNT(DISTINCT #{subj_table}.id)" +
          #                        "FROM #{subj_table} INNER JOIN #{join_table} ON #{subj_col}_id = #{subj_table}.id " +
          #                        "INNER JOIN #{role_table} ON #{role_table}.id = #{role.underscore}_id " +
          #                        "WHERE authorizable_type = '#{self.class.base_class.to_s}' AND authorizable_id = #{id} "},
          # :readonly => true

        include Acl9::ModelExtensions::ForObject
      end
    end
  end
end

ActionDispatch::ExceptionWrapper.rescue_responses['Acl9::AccessDenied'] = :not_found
