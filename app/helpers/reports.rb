module ReportsHelper
  def sales_current_month
    Cabang.get_id.each do |cabang|
      {
        cabang: Cabang.find(cabang),
        quantity: TmpBrand.where('cabang_id = ? and bulan = ?', cabang, Date.today.monh)
      }
    end
  end
end
