class ChangeForeignKeysFromUuidToId < ActiveRecord::Migration[5.2]
  def up
    def up
      id_to_uuid("urls", "organization", "organizations")
      id_to_uuid("users", "organization", "organizations")
      id_to_uuid("articles", "category", "categories")
      id_to_uuid("articles", "organization", "organizations")
      id_to_uuid("article_urls", "url", "urls")
      id_to_uuid("article_urls", "article", "articles")
    end

    def id_to_uuid(table_name, relation_name, relation_class)
      table_name = table_name.to_sym
      klass = table_name.to_s.classify.constantize
      relation_klass = relation_class.to_s.classify.constantize
      foreign_key = "#{relation_name}_id".to_sym
      new_foreign_key = "#{relation_name}_uuid".to_sym

      add_column table_name, new_foreign_key, :uuid

      klass.where.not(foreign_key => nil).each do |record|
        if associated_record = relation_klass.find_by(id: record.send(foreign_key))
          record.update_column(new_foreign_key, associated_record.uuid)
        end
      end

      remove_column table_name, foreign_key
      rename_column table_name, new_foreign_key, foreign_key
    end
  end
end
