module User::Searchable
  # Replace with a search engine like Meilisearch, ElasticSearch, or pg_search to provide better results
  # Using arel matches allows for database agnostic like queries

  extend ActiveSupport::Concern

  class_methods do
    def search(query)
      case connection.adapter_name
      when "SQLite"
        first_name, last_name = query.split(" ", 2)
        if last_name.present?
          where(arel_table[:first_name].matches("%#{sanitize_sql_like(first_name)}%")).where(arel_table[:last_name].matches("%#{sanitize_sql_like(last_name)}%"))
        else
          where(arel_table[:first_name].matches("%#{sanitize_sql_like(query)}%")).or(where(arel_table[:last_name].matches("%#{sanitize_sql_like(query)}%")))
        end
      else
        where(arel_table[:name].matches("%#{sanitize_sql_like(query)}%"))
      end
    end
  end
end
