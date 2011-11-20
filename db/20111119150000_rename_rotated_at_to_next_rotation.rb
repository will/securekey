Sequel.migration do
  change do
    alter_table(:users) do
      drop_index :rotated_at
      drop_column :rotated_at
      add_column :next_rotation, :timestamptz
      add_index :next_rotation
    end
  end
end
