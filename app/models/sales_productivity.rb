class SalesProductivity < ActiveRecord::Base
  validates :salesmen_id, :brand_id, presence: true

  def self.generate_productivity
    all.each do |sf|
      nama_sales = User.find(sf.salesmen_id).nama
      sum_sold_product = self.find_by_sql("SELECT SUM(jumlah) AS jumlah FROM tblaporancabang WHERE salesman LIKE '#{nama_sales}%' AND cabang_id = '#{sf.branch_id}'").first
      unless sum_sold_product.jumlah.nil?
        sum_visit = SalesProductivity.where(salesmen_id: sf.salesmen_id).sum("nvc")
        sum_close_deal_visit = SalesProductivity.where(salesmen_id: sf.salesmen_id).sum("ncdv")
        sum_call_close_deal = SalesProductivity.where(salesmen_id: sf.salesmen_id).sum("ncdc")
        sum_call_customer = SalesProductivity.where(salesmen_id: sf.salesmen_id).sum("ncc")
        average_visit_day = (sum_visit.to_f/sf.created_at.day.to_f)%100.0
        success_rate_visit = (sum_close_deal_visit.to_f/sum_visit.to_f)%100.0
        order_visit = (sum_sold_product.jumlah/sum_call_close_deal.to_f)%100.0
        call_day = (sum_sold_product.jumlah/sf.created_at.day.to_f)%100.0
        find_sales_report = SalesProductivityReport.where(salesmen_id: sf.salesmen_id, month: sf.updated_at.month,
        year: sf.updated_at.year, brand: sf.brand)
        if find_sales_report.empty?
          SalesProductivityReport.create(salesmen_id: sf.salesmen_id, branch_id: sf.branch_id,
          brand: sf.brand, month: sf.updated_at.month, year: sf.updated_at.year,
          average_visit_day: average_visit_day, success_rate_visit: success_rate_visit,
          average_order_deal: order_visit.is_a?(Float) ? 0 : order_visit, average_call_day: call_day)
        else
          find_sales_report.first.update_attributes!(average_visit_day: average_visit_day, success_rate_visit: success_rate_visit,
          average_order_deal: order_visit.is_a?(Float) ? 0 : order_visit, average_call_day: call_day)
        end
      end
    end
  end
end