class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :content
      t.boolean :outbound
      t.boolean :inbound

      t.timestamps
    end
  end
end
