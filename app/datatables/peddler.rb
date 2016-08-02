class Peddler
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view, pa)
    @pa = pa
    @view = view
  end

  def item_available
    @items ||= fetch_items
  end

  def fetch_items
    item_available = JdeItemAvailability.select("liitm as liitm, sum(lipqoh) as lipqoh, sum(lihcom) as lihcom").where("limcu like ? and lipqoh >= ?", "%#{@pa}", 1).order("#{sort_column} #{sort_direction}").group("liitm")
    item_available = item_available.page(page).per_page(per_page)
    if params[:sSearch].present?
      item_master = JdeItemMaster.where("imlitm like ? or imdsc1 like ? and imtmpl like ? and imseg4 like ?", "%#{params[:sSearch]}%", "%#{params[:sSearch]}%", "%BJ MATRASS%", "%S%")
      item_available = item_available.where("liitm IN (?)", item_master)
    end
    item_available
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: JdeItemAvailability.where("limcu like ? and lipqoh >= ?", "%#{@pa}", 1).count,
      iTotalDisplayRecords: item_available.total_entries,
      aaData: data
    }
  end

  private
  def data
    first_week_date = Date.today.beginning_of_week
    last_week_date = Date.today.end_of_week
    item_available_s = []
    item_available.map do |ia|
      im = JdeItemMaster.where(imitm: ia.liitm).where("imstkt not like ? and imseg4 not like ?", "%O%", "%T%")
      if im.present?
        item_available_s << ia
      end
    end
    item_available_s.map do |ia|
      im = JdeItemMaster.where(imitm: ia.liitm)
      item_available= ia.lipqoh - ia.lihcom
      [
        h(im.first.imlitm.strip),
        h(im.first.imdsc1.strip)+" "+(im.first.imdsc2.strip),
        h(BigDecimal(item_available.to_s)).to_s.gsub(/0/,""),
        h(""),
        h(JdeSoDetail.outstanding_so(ia.liitm, first_week_date, last_week_date).first.sduorg).to_s.gsub(/0/,""),
        h(JdeSoDetail.delivered_so(ia.liitm, first_week_date, last_week_date).first.sdsoqs).to_s.gsub(/0/,""),
        h(""),
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

