class ChangeColumnTypesToUuids < ActiveRecord::Migration[5.2]
  def up
    execute("ALTER TABLE articles ALTER COLUMN category_id SET DATA TYPE UUID USING (uuid(lpad(replace(text(category_id),'-',''), 32, '0')))");
    execute("ALTER TABLE articles ALTER COLUMN organization_id SET DATA TYPE UUID USING (uuid(lpad(replace(text(organization_id),'-',''), 32, '0')))");

    execute("ALTER TABLE article_urls ALTER COLUMN article_id SET DATA TYPE UUID USING (uuid(lpad(replace(text(article_id),'-',''), 32, '0')))");
    execute("ALTER TABLE article_urls ALTER COLUMN url_id SET DATA TYPE UUID USING (uuid(lpad(replace(text(url_id),'-',''), 32, '0')))");

    execute("ALTER TABLE urls ALTER COLUMN organization_id SET DATA TYPE UUID USING (uuid(lpad(replace(text(organization_id),'-',''), 32, '0')))");
  end
end
