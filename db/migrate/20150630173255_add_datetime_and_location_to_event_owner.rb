class AddDatetimeAndLocationToEventOwner < ActiveRecord::Migration
  def change
    add_column :event_owners, :from_event, :datetime
    add_column :event_owners, :to_event, :datetime
    add_column :event_owners, :location, :text
  end
end
