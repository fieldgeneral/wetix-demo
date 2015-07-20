class AddAttendeeListToEventOwners < ActiveRecord::Migration
  def change
    add_column :event_owners, :attendee_list, :text
  end
end
