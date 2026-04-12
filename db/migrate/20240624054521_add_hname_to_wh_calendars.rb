class AddHnameToWhCalendars < ActiveRecord::Migration[7.1]
  def change
    add_column :wh_calendars ,:hname, :string, :limit =>64
  end
end
