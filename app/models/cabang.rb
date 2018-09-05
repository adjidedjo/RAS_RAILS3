class Cabang < ActiveRecord::Base
  set_table_name "tbidcabang"
  has_many :stock
  has_many :barang,  :through => :stock
  has_many :laporan_cabang
  has_many :monthly_target
  has_many :yearly_target
  has_many :regional, :through => :regional_branches
  has_many :regional_branches

  scope :branch_name, lambda {|branch| where(:id => branch)}

  def self.branch_get_name(current_user)
    current_user.branch == nil ? get_id : branch_name(current_user.branch)
  end

  def self.get_id
    find(1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 13, 18, 19, 20, 22, 23, 24)
  end

  def self.get_id_to_7
    find(1, 2, 3, 4, 5, 7, 8, 9, 10)
  end

  def self.get_id_to_22
    find(11, 13, 18, 19, 20, 22, 23, 24)
  end
  
  def self.branch_description(cabang)
    find_by_sql("SELECT Cabang FROM tbidcabang WHERE IdCabang like '#{cabang}'").first
  end

end