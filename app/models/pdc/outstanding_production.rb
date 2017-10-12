class Pdc::OutstandingProduction < ActiveRecord::Base
  establish_connection "production-analysis"
  self.table_name = "outstanding_productions" #sd
  
  def self.generate_outstanding_stock
    self.all.each do |op|
      so_in = Pdc::SalesOrder.find_by_short_item_and_branch(op.short_item, op.branch)
      so_outstanding = Pdc::OutstandingOrder.get_quantity(op.short_item, op.branch)
      buffer = Pdc::ProductionStock.find_by_short_item_and_branch(op.short_item, op.branch)
      stockf = Pdc::ProductionStock.where("short_item = '#{op.short_item}' AND branch LIKE '#{op.branch}%' AND status = 'F'")
      stockc = Pdc::ProductionStock.where("short_item = '#{op.short_item}' AND branch LIKE '#{op.branch}%' AND status = 'C'")
      op.update_attributes!(order_in: so_in.quantity) if so_in
      op.update_attributes!(outstanding_order: so_outstanding.sum_quatity, segment1: so_outstanding.segment1) if so_outstanding
      op.update_attributes!(buffer: buffer.buffer) if buffer
      op.update_attributes!(onhand: stockf.first.onhand) unless stockf.empty?
      op.update_attributes!(stock_f: stockf.first.available) unless stockf.empty?
      op.update_attributes!(stock_c: stockc.first.onhand) unless stockc.empty?
    end
  end
end