class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.string :voter
      t.integer :candidate_id
      t.integer :poll_id
      t.integer :priority

      t.timestamps null: false
    end
  end
end
