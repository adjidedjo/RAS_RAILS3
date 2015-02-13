class CostOfGood < ActiveRecord::Base

  attr_accessible :merk, :diskon1, :diskon2, :price_list, :net_a_diskon, :paket, :top, :point, :kontrak, :artikel, :ukuran, :cabang_id,
    :customer, :margin1, :margin2, :margin3, :margin4, :margin5, :margin_percent, :central, :lrv, :incentive_sales,
    :incentive_sales_m, :ongkir, :hpp, :b_mkt, :b_mkt_m, :bhbo, :total_bonus, :net_a_incentive, :margin_m, :margin, :produk
  before_save :find_net

  def find_net
    kodebarang = produk+artikel
    coi_kode = CostOfItem.where("kodebarang like '#{kodebarang}%' and kodebarang like '%S%'
and kodebarang like '%#{ukuran}%' " ).first
    pl_kode = PriceList.where("produk like ? and cabang_id = ?", artikel, cabang_id).first
    self.price_list = pl_kode.harga
    self.hpp = coi_kode.hpp
    net_after_diskon = (pl_kode.harga - (pl_kode.harga*diskon1/100) - (pl_kode.harga - (pl_kode.harga*diskon1/100))*diskon2/100)
    self.net_a_diskon = net_after_diskon
    self.net_a_top = (paket - (paket*top/100))
    self.net_a_poin = self.net_a_top - (self.net_a_top*((point.to_f)/100))
    self.net_a_kontrak = self.net_a_poin - (self.net_a_poin*kontrak/100)
    self.net_a_lrv = self.net_a_kontrak - (self.net_a_kontrak*(lrv.nil? ? 0 : (lrv/100)))
    self.incentive_sales_m = self.net_a_diskon*incentive_sales/100
    self.net_a_incentive = self.net_a_lrv-self.incentive_sales_m
    self.b_mkt_m = coi_kode.hpp.to_i*b_mkt/100
    self.bhbo =  self.b_mkt_m+(total_bonus.nil? ? 0 : total_bonus)+(ongkir.nil? ? 0 : ongkir)+coi_kode.hpp.to_i
    self.margin_m = self.net_a_incentive-self.bhbo
    self.margin =  self.margin_m/self.net_a_incentive
  end
end
