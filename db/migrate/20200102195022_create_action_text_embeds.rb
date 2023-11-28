class CreateActionTextEmbeds < ActiveRecord::Migration[6.0]
  def change
    create_table :action_text_embeds do |t|
      t.string :url
      if t.respond_to? :jsonb
        t.jsonb :fields
      else
        t.json :fields
      end

      t.timestamps
    end
  end
end
