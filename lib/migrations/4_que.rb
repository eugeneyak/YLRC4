require "que"
require "sequel"

Sequel.migration do
  Que.connection = Sequel::Model.db

  up { Que.migrate!(version: 7) }
  down { Que.migrate!(version: 0) }
end
