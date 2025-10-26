Sequel.migration do
  change do
    create_table :services do
      primary_key :id

      column :user_id, :integer
      column :message_ids, "integer[]", null: false, default: Sequel.lit("ARRAY []::integer[]")

      column :brand, :text
      column :model, :text
      column :plate, :text
      column :vin, :text
      column :mileage, :integer

      column :photos, "text[]", null: false, default: Sequel.lit("ARRAY []::text[]")

      column :created_at, :timestamp, nullable: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
