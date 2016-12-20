class SalesProductivity < ActiveRecord::Base
  validates :salesmen_id, :brand_id, presence: true

  after_create do
    sum_visit = SalesProductivity.where(salesmen_id: self.salesmen_id).sum("nvc")
    sum_close_deal_visit = SalesProductivity.where(salesmen_id: self.salesmen_id).sum("ncdv")
    sum_sold_product = SalesProductivity.where(salesmen_id: self.salesmen_id).sum("apt")
    sum_call_close_deal = SalesProductivity.where(salesmen_id: self.salesmen_id).sum("ncdc")
    sum_call_customer = SalesProductivity.where(salesmen_id: self.salesmen_id).sum("ncc")
    average_visit_day = (sum_visit.to_f/self.created_at.day.to_f)%100.0
    success_rate_visit = (sum_close_deal_visit.to_f/sum_visit.to_f)%100.0
    order_visit = (sum_sold_product.to_f/sum_call_close_deal.to_f)%100.0
    call_day = (sum_sold_product.to_f/self.created_at.day.to_f)%100.0
    find_sales_report = SalesProductivityReport.where(salesmen_id: self.salesmen_id, month: self.updated_at.month,
    year:self.updated_at.year, brand_id: self.brand_id)
    if find_sales_report.empty?
      SalesProductivityReport.create(salesmen_id: self.salesmen_id, branch_id: self.branch_id,
      brand_id: self.brand_id, month: self.updated_at.month, year:self.updated_at.year,
      average_visit_day: average_visit_day, success_rate_visit: success_rate_visit,
      average_order_deal: order_visit, average_call_day: call_day)
    else
      find_sales_report.first.update_attributes!(average_visit_day: average_visit_day, success_rate_visit: success_rate_visit,
      average_order_deal: order_visit, average_call_day: call_day)
    end
  end
end