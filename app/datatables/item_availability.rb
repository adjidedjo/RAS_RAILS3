class ItemAvailability
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def item_available
    @items ||= fetch_items
  end

  def fetch_items
    item_available = JdeItemAvailability.where("limcu like ? and lipqoh >= ?", "%11011", 1).order("#{sort_column} #{sort_direction}")
    item_available = item_available.page(page).per_page(per_page)
    if params[:sSearch].present?
      item_master = JdeItemMaster.where("imlitm like :search", search: "%#{params[:sSearch]}%" )
      item_available = item_available.where("liitm like :search", search: item_master.first.imitm)
    end
    item_available
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: JdeItemAvailability.where("limcu like ? and lipqoh >= ?", "%11011", 1).count,
      iTotalDisplayRecords: item_available.total_entries,
      aaData: data
    }
  end

  private
  def data
    item_available.map do |ia|
      im = JdeItemMaster.where(imitm: ia.liitm).first
      available = ia.lipqoh - ia.lihcom
      [
        h(ia.lilotn.strip),
        h(im.imlitm.strip),
        h(im.imdsc1.strip)+" "+(im.imdsc2.strip),
        h(BigDecimal(ia.lipqoh.to_s)).gsub(/0/,""),
        h(BigDecimal(available.to_s)).to_s.gsub(/0/,"")
      ]
    end
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[liitm]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

