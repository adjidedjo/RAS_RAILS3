class Pdc::BranchNeed < ActiveRecord::Base
  establish_connection "production-analysis"
  def self.get_quantity(itm, branch)
    find_by_sql("SELECT segment1, SUM(quantity) AS sum_quatity FROM outstanding_orders
    WHERE short_item = '#{itm}' AND branch = '#{branch}'
    GROUP BY item_number, branch").first
  end
end