Sequel.migration do
  change do
    create_table :users do
      primary_key :id, :integer

      column :first_name, :text
      column :last_name, :text
      column :username, :text

      column :premium, :boolean, default: false
      column :bot, :boolean, default: false

      column :language_code, :text
    end
  end
end
