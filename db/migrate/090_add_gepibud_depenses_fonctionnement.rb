class AddGepibudDepensesFonctionnement < ActiveRecord::Migration
  def self.up
    add_column :depense_fonctionnements, :prestation_service, :boolean,  :default => false

  end

  def self.down
    remove_column :depense_fonctionnements, :prestation_service
  end
end
