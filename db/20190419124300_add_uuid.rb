Sequel.migration do
  up do
    run 'CREATE EXTENSION "uuid-ossp"'
    alter_table(:users) do
      add_column :uuid, :uuid
    end
  end
end
