Sequel.migration do
  change do
    create_table :dialogues do
      column :user_id, :integer, null: false
      column :step, :text, nullable: false
      column :entity, :text, nullable: false
      column :entity_id, :integer, nullable: false
      column :trace_id, :text, nullable: false
      column :created_at, :timestamp, nullable: false, default: Sequel::CURRENT_TIMESTAMP
      column :completed_at, :timestamp
    end
  end
end
