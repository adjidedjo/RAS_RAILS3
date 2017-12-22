class AsongOrder < ActiveRecord::Base
  after_create :creating_point
  def creating_point
    check_stock = checking_stock(self.short_item, self.branch_plant)
    aln = AsongLotNumber.find_by_sql("SELECT lot_number FROM asong_lot_numbers WHERE
    short_item = '#{self.short_item}' and branch = '#{self.branch_plant}'")
    check_stock = check_stock -= aln
    choosen_lot = []
    if check_stock.present?
      val_params = check_stock.count < self.quantity.to_i ? check_stock : check_stock.first(self.quantity.to_i)
      val_params.each do |a|
        al = AsongLotNumber.create!(asong_order_id: self.id, lot_number: a.lilotn, branch: self.branch_plant,
        short_item: self.short_item)
        AsongPoint.create!(asong_order_id: self.id, branch: self.branch, brand: self.brand, point: 1)
      end
    end
  end

  def checking_stock(short_item, branch_plant)
    JdeItemAvailability.checking_stock_asong(short_item, branch_plant)
  end
end