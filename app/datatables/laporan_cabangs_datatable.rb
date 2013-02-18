delegate :params, :h, :link_to, :number_to_currency, to: :@view

def initialize(view)
  @view = view
end

def as_json(options = {})
  {
    sEcho: params[:sEcho].to_i,
    iTotalRecords: LaporanCabang.count,
    iTotalDisplayRecords: laporancabang.total_entries,
    aaData: data
  }
end

private
def data
  laporancabang.map do |laporan|
    [
      link_to(laporan.tanggalfaktur, laporan),
      h(laporan.idcabang)
    ]
  end
end

def fetch_laporancabang
  laporancabang = LaporanCabang.order("#{sort_column} #{sort_direction}")
  laporancabang = laporancabang.page(page).per_page(per_page)
  if params[:dari_tanggal].present? && params[:ke_tanggal]
    laporancabang = laporancabang.where("tanggalfaktur like :search or customer like :search", search: "%#{params[:sSearch]}%")
  end
  laporancabang
end