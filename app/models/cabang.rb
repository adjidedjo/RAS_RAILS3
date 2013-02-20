class Cabang < ActiveRecord::Base
  set_table_name "tbidcabang"
  has_many :laporan_cabang
end