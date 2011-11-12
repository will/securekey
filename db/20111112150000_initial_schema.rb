Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      column :heroku_id, :text
      column :plan, :text
      column :created_at, :timestamptz, :default => "now()".lit
      column :callback_url, :text
    end
  end
end
