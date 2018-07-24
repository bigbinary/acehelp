desc "list missing foreign keys"
task list_missing_foreign_keys: [:environment, :not_production] do
  ActiveRecord::Base.logger.level = 1
  c = ActiveRecord::Base.connection; nil

  puts "============== missing FK"

  c.tables.collect do |t|
    columns = c.columns(t).collect(&:name).select {|x| x.ends_with?("_id" || x.ends_with("_type"))}
    fk_columns = c.foreign_keys(t).collect{ |fk| fk.options[:column] }.flatten.uniq
    missing_fk_columns = columns - fk_columns
    unless missing_fk_columns.empty?
      puts "#{t}: #{missing_fk_columns.join(", ")}"
    end
  end; nil

  puts "============== missing FK indexes"

  c.tables.collect do |t|
    columns = c.columns(t).collect(&:name).select {|x| x.ends_with?("_id" || x.ends_with("_type"))}
    indexed_columns = c.indexes(t).collect(&:columns).flatten.uniq
    unindexed = columns - indexed_columns
    unless unindexed.empty?
      puts "#{t}: #{unindexed.join(", ")}"
    end
  end; nil

  ActiveRecord::Base.logger.level = 0
end