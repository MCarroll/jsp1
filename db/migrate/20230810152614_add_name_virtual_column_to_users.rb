class AddNameVirtualColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    case connection.adapter_name
    when "SQLite"
      # Rails doesn't support virtual columns for SQLite yet
      # add_column :users, :name, :virtual, type: :string, as: "first_name || ' ' || coalesce(last_name, '')", stored: true
    else
      add_column :users, :name, :virtual, type: :string, as: "CONCAT_WS(' ', first_name, last_name)", stored: true
    end
  end
end
