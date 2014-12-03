class CreateLemurs < ActiveRecord::Migration
  def change
    create_table :lemurs do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
