class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :comment

      t.timestamps
    end
  end
end
