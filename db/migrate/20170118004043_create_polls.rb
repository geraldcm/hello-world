class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.string :name
      t.boolean :open

      t.timestamps null: false
    end
  end
end