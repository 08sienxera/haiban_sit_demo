class AddRemindFieldsAndLastLogintimeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users ,:remind_question, :string, :limit =>32
    add_column :users ,:remind_answer, :string, :limit =>32
    add_column :users ,:last_logined_at, :datetime
  end
end
