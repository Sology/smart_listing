class User < ActiveRecord::Migration
  def change
    create_table "users", force: true do |t|
      t.string "name"
      t.string "email"
    end
  end
end
