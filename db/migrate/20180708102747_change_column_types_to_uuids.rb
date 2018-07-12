class ChangeColumnTypesToUuids < ActiveRecord::Migration[5.2]
  def up
    execute("ALTER TABLE articles ALTER COLUMN category_id SET DATA TYPE UUID USING (gen_random_uuid())");
    execute("ALTER TABLE articles ALTER COLUMN organization_id SET DATA TYPE UUID USING (gen_random_uuid())");

    execute("ALTER TABLE article_urls ALTER COLUMN article_id SET DATA TYPE UUID USING (gen_random_uuid())");
    execute("ALTER TABLE article_urls ALTER COLUMN url_id SET DATA TYPE UUID USING (gen_random_uuid())");

    execute("ALTER TABLE urls ALTER COLUMN organization_id SET DATA TYPE UUID USING (gen_random_uuid())");
  end
end
