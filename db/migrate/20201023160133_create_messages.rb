class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :MessageUUID
      t.string :Text
      t.bigint :From
      t.bigint :To
      t.boolean :isoutgoing

      t.timestamps
    end
  end
end
