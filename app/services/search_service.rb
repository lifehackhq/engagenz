class SearchService
  def self.find(region: nil, categories: nil)
    Provider.where(region_id: region).
             joins(:categories).where(type_id: type)
  end


end