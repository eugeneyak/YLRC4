require "sequel"

Sequel.extension :migration

DB = Sequel.postgres(
  database: Config::DB::DATABASE,
  host: Config::DB::HOST,
  port: Config::DB::PORT,
  user: Config::DB::USER,
  password: Config::DB::PASSWORD
)

DB.extension :pg_json

Sequel::Model.unrestrict_primary_key
