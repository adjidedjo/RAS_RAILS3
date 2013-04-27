class LaporanCabangDatatable
	delegate :params, :h, :link_to, :number_to_currency, to: :@view

	def initialize(view)
		@view = view
	end

	def as_json(options = {})
		{
		  sEcho: params[:sEcho].to_i,
		  iTotalRecords: laporancabang.count,
		  iTotalDisplayRecords: laporancabang.count,
		  aaData: data
		}
	end


	private
	def data
    laporancabang = LaporanCabang.find(:all, :conditions => ["customer not like ? and tanggalsj between ? and ?", 'cab%',
          "01/04/2013".to_date, "19/04/2013".to_date],
        :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg")
		laporancabang.map do |laporan|
		  [
				h(laporan.cabang.Cabang.gsub(/Cabang/, "")),
		  	h(laporan.customer),
        h(laporan.tanggalsj.strftime("%B")),
        h(laporan.tanggalsj.strftime("%Y")),
        h(laporan.jenisbrgdisc),
        h(laporan.namabrand),
        h(laporan.jenisbrg),
        h(laporan.namaartikel),
        h(laporan.namakain),
        h(laporan.panjang),
        h(laporan.lebar),
        h(laporan.sum_jumlah.to_i),
        h(laporan.sum_harganetto2.to_i)
		  ]
		end
	end

  def laporancabang
    @laporancabang ||= fetch_laporancabang
  end

	def fetch_laporancabang
		laporancabang1 = LaporanCabang.find(:all, :order => "#{sort_column} #{sort_direction}", :conditions => ["customer not like ? and tanggalsj between ? and ?", 'cab%',
          "01/04/2013".to_date, "19/04/2013".to_date],
        :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel,
        namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg")
		laporancabang = laporancabang1.paginate(:page => page, :per_page => per_page)
		if params[:sSearch].present?
      laporancabang = LaporanCabang.find(:all, :conditions => ["customer like ? and tanggalsj between ? and ?", "%#{params[:sSearch]}%","01/04/2013".to_date, "19/04/2013".to_date], :select => "tanggalsj, cabang_id, customer, jenisbrgdisc, namabrand, jenisbrg, namaartikel, namakain, panjang, lebar, sum(jumlah) as sum_jumlah, sum(harganetto2) as sum_harganetto2",
        :group => "customer, kodebrg")
    end
    laporancabang
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[customer cabang_id]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
