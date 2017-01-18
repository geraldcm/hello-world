class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string :name
      t.integer :poll_id

      t.timestamps null: false
    end
  end
end
