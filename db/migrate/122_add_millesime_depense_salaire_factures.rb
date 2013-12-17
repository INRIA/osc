class AddMillesimeDepenseSalaireFactures < ActiveRecord::Migration
  def change
    add_column :depense_salaire_factures, :millesime, :date, :default => nil
  end
end
