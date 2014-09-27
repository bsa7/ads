class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.belongs_to :classified_ad, index: true
      t.string :comment

      t.timestamps
    end
  end
end
