module TypePere
	
  def find_type_pere(contrat_type)
		parent_type = ContratType.find(contrat_type).parent_id
		return contrat_type if parent_type == 0
		find_type_pere(parent_type)
	end
end