class UpdateDepenseSalaires < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `depense_salaires` CHANGE `nb_mois` `nb_mois` DECIMAL( 10, 2 ) NULL DEFAULT NULL"  
  end

  def self.down
    execute "ALTER TABLE `depense_salaires` CHANGE `nb_mois` `nb_mois` INT( 11 ) NULL DEFAULT NULL"
  end
end
