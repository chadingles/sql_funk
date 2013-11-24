# SqlFunk

require 'active_record'

module SqlFunk
  # def self.included(base)
  #   base.send :extend, ClassMethods
  # end
  
  module Base
    
    def count_by(column_name, options = {})
      options[:order] ||= 'ASC'
      options[:group_by] ||= 'day'
      options[:group_column] ||= options[:group_by]
      strftime_options = {
        :day => "%Y-%m-%d",
        :week => case ActiveRecord::Base.connection.adapter_name.downcase
          when /^sqlite/ then "%W"
          when /^mysql/ then "%U"
          end,
        :month => "%Y-%m",
        :year => "%Y"
      }

      date_func = case ActiveRecord::Base.connection.adapter_name.downcase
        when /^sqlite/ then "STRFTIME(\"#{strftime_options[options[:group_by].to_sym]}\", #{self.table_name}.#{column_name})"
        when /^mysql/ then "DATE_FORMAT(#{self.table_name}.#{column_name}, #{strftime_options[options[:group_by].to_sym]})"
        when /^postgresql/ then "DATE_TRUNC('#{options[:group_by]}', \"#{self.table_name}\".\"#{column_name}\")"
        end          

      self.select("#{date_func} AS #{options[:group_column]}, COUNT(*) AS counter").group(options[:group_column]).order("#{options[:group_column]} #{options[:order]}")
    end
    # 
    # def method_missing(id, *args, &block)
    # 
    #   return count_by(args[0], { :group_by => "day" }.merge(args[1]))
    # 
    #   # return count_by(args[0], { :group_by => "day" }.merge(args[1])) if id.id2name == /count_by_day/
    #   #     
    #   # return count_by(args[0], { :group_by => Regexp.last_match(1) }.merge(args[1])) if id.id2name =~ /count_by_(.+)/
    # 
    # end
    
  end

end
