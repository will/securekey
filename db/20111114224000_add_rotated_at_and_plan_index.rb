Sequel.migration do
  change do
    alter_table(:users) do
      add_column :rotated_at, :timestamptz
      add_index :rotated_at
      add_index :plan
    end
  end
end
