class UpdateRubriqueComptable < ActiveRecord::Migration
  def self.up
    add_column :rubrique_comptables, :numero_rubrique, :string,:default => ""
    rename_column :rubrique_comptables, :intitule, :label
    rubrique_comptables = RubriqueComptable.find(:all)
    for rubrique_comptable in rubrique_comptables do
      tmp_label = rubrique_comptable.label.split("-")
      rubrique_comptable.numero_rubrique = tmp_label.first
      if tmp_label.size > 1
        rubrique_comptable.label = tmp_label.last        
      else
        rubrique_comptable.label = ""        
      end
      rubrique_comptable.save
    end
    
  end

  def self.down
    rubrique_comptables = RubriqueComptable.find(:all)
    for rubrique_comptable in rubrique_comptables do
      if rubrique_comptable.label != ''
        tmp_label = rubrique_comptable.numero_rubrique + ' - '+ rubrique_comptable.label  
      else
        tmp_label = rubrique_comptable.numero_rubrique
      end
      
      rubrique_comptable.label = tmp_label
      rubrique_comptable.save
    end
    remove_column :rubrique_comptables, :numero_rubrique
    rename_column :rubrique_comptables, :label, :intitule
    
  end
end
