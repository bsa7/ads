class CreateClassifiedAds < ActiveRecord::Migration
  def change
    create_table :classified_ads do |t|
      t.text :plain_text

      t.timestamps
    end
  end
end
