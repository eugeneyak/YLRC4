Sequel.migration do
  change do
    create_table :updates do
      primary_key :update_id

      column :created_at, :timestamp
      column :payload, :jsonb
    end
  end
end
