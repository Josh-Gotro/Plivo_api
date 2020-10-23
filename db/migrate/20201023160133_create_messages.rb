class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :content
      t.bigint :myphone
      t.bigint :yourphone
      t.boolean :isoutgoing

      t.timestamps
    end
  end
end
