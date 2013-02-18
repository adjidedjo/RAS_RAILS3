# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130209023858) do

  create_table "dtproperties", :id => false, :force => true do |t|
    t.integer "id",                                            :null => false
    t.integer "objectid"
    t.string  "property", :limit => 64,                        :null => false
    t.string  "value"
    t.string  "uvalue"
    t.binary  "lvalue",   :limit => 2147483647
    t.integer "version",                        :default => 0, :null => false
  end

  create_table "laporansj", :primary_key => "nomor", :force => true do |t|
    t.string   "idcabang",     :limit => 5
    t.string   "NamaCabang",   :limit => 50
    t.string   "noSJ",         :limit => 50
    t.datetime "tanggalSJ"
    t.string   "Customer",     :limit => 100
    t.string   "kodebrg",      :limit => 25
    t.string   "namabrg",      :limit => 150
    t.string   "namabrand",    :limit => 50
    t.string   "jenisbrgdisc", :limit => 50
    t.string   "kodejenis",    :limit => 5
    t.string   "jenisbrg",     :limit => 100
    t.string   "kodeartikel",  :limit => 8
    t.string   "Artikel",      :limit => 50
    t.string   "kodekain",     :limit => 10
    t.string   "namakain",     :limit => 100
    t.string   "panjang",      :limit => 5
    t.string   "lebar",        :limit => 5
    t.integer  "jumlah"
    t.float    "harga"
    t.string   "bonus",        :limit => 10
  end

  create_table "laporansjtmp", :id => false, :force => true do |t|
    t.integer  "nomor"
    t.string   "idcabang",     :limit => 5
    t.string   "NamaCabang",   :limit => 50
    t.string   "noSJ",         :limit => 50
    t.datetime "tanggalSJ"
    t.string   "Customer",     :limit => 100
    t.string   "kodebrg",      :limit => 25
    t.string   "namabrg",      :limit => 150
    t.string   "namabrand",    :limit => 50
    t.string   "jenisbrgdisc", :limit => 50
    t.string   "kodejenis",    :limit => 5
    t.string   "jenisbrg",     :limit => 100
    t.string   "kodeartikel",  :limit => 8
    t.string   "Artikel",      :limit => 50
    t.string   "kodekain",     :limit => 10
    t.string   "namakain",     :limit => 100
    t.string   "panjang",      :limit => 5
    t.string   "lebar",        :limit => 5
    t.integer  "jumlah"
    t.float    "harga"
  end

  create_table "report1", :force => true do |t|
    t.string "noIp",   :limit => 20
    t.string "Cabang", :limit => 35
    t.float  "sl1"
    t.float  "sl2"
    t.float  "st1"
    t.float  "st2"
    t.float  "nl1"
    t.float  "nl2"
    t.float  "nt1"
    t.float  "nt2"
    t.float  "cl1"
    t.float  "cl2"
    t.float  "ct1"
    t.float  "ct2"
  end

  create_table "report2", :force => true do |t|
    t.string "NoIp",   :limit => 20
    t.string "Cabang", :limit => 35
    t.float  "El"
    t.float  "Et"
    t.float  "Cl"
    t.float  "Ct"
  end

  create_table "report3", :force => true do |t|
    t.string  "NoIP",   :limit => 20
    t.string  "Cabang", :limit => 35
    t.float   "El"
    t.float   "Et"
    t.float   "Cl"
    t.float   "Ct"
    t.integer "bulan"
    t.integer "tahun"
  end

  create_table "sysfiles2", :id => false, :force => true do |t|
    t.datetime "tanggal", :null => false
  end

  create_table "target1", :force => true do |t|
    t.string  "cabang", :limit => 35
    t.integer "bulan"
    t.integer "tahun"
    t.string  "brand",  :limit => 15
    t.float   "jumlah"
  end

  create_table "target2", :force => true do |t|
    t.string  "cabang", :limit => 35
    t.integer "tahun"
    t.string  "brand",  :limit => 15
    t.string  "jumlah", :limit => 53
  end

  create_table "tb_forcash", :primary_key => "nomor", :force => true do |t|
    t.string  "kodebrg", :limit => 20
    t.integer "bulan"
    t.integer "tahun"
    t.string  "jumlah",  :limit => 10
  end

  create_table "tbbjkodeartikel", :id => false, :force => true do |t|
    t.string  "KodeBrand",      :limit => 2
    t.string  "KodeCollection", :limit => 6,                                  :null => false
    t.string  "Produk",         :limit => 200,                                :null => false
    t.string  "KodeProduk",     :limit => 2,                                  :null => false
    t.string  "Status",         :limit => 5
    t.string  "OldName",        :limit => 200
    t.integer "Aktif"
    t.integer "varpoint",       :limit => 8
    t.decimal "divpoint",                      :precision => 19, :scale => 0
  end

  create_table "tbbjkodebrand", :id => false, :force => true do |t|
    t.string "KodeBrand", :limit => 2,  :null => false
    t.string "NamaBrand", :limit => 50
    t.float  "PcntPoin"
    t.float  "DivPoin"
  end

  create_table "tbbjkodekain", :force => true do |t|
    t.string  "KodeKain",       :limit => 5,  :null => false
    t.string  "NamaKain",       :limit => 50
    t.string  "KodeCollection", :limit => 4
    t.string  "Status",         :limit => 5
    t.integer "Aktif"
  end

  create_table "tbbjkodeproduk", :primary_key => "KodeProduk", :force => true do |t|
    t.string "Namaroduk", :limit => 100
  end

  create_table "tbbjkodeukuran", :id => false, :force => true do |t|
    t.string "IdUkuran",   :limit => 10
    t.string "Ukuran",     :limit => 50
    t.float  "Panjang"
    t.float  "Lebar"
    t.string "KodeProduk", :limit => 2
  end

  create_table "tbcabbarang", :id => false, :force => true do |t|
    t.string  "KodeBrg",                                                     :null => false
    t.string  "Nama"
    t.string  "Alias"
    t.string  "IdGrup"
    t.string  "Keterangan"
    t.boolean "Aktif",                                                       :null => false
    t.float   "StockMin"
    t.float   "StockMax"
    t.string  "IdSatuan"
    t.string  "IdSatuanBeli"
    t.float   "Kelipatan"
    t.string  "IdGudang"
    t.string  "IdSupp"
    t.float   "LeadTime"
    t.string  "IdJenis"
    t.float   "Panjang"
    t.float   "Lebar"
    t.string  "IdMerk"
    t.string  "Kain"
    t.string  "Ukuran"
    t.float   "HargaBrg"
    t.string  "idjenisbrgdisc"
    t.string  "idCabang",       :limit => 20,                                :null => false
    t.decimal "UpGradeSize",                  :precision => 19, :scale => 4
  end

  create_table "tbcabfaktur", :id => false, :force => true do |t|
    t.integer "idurut",                 :null => false
    t.string  "nofaktur", :limit => 50, :null => false
    t.string  "id",       :limit => 50
  end

  add_index "tbcabfaktur", ["id"], :name => "FK_tbCabFaktur_tbImportMCabang"

  create_table "tbcabimportstock", :id => false, :force => true do |t|
    t.string   "idCabang",    :limit => 2,   :null => false
    t.string   "Cabang",      :limit => 50,  :null => false
    t.string   "KodeBrg",     :limit => 50,  :null => false
    t.string   "Nama",        :limit => 150
    t.integer  "Saldo",                      :null => false
    t.datetime "Tanggal",                    :null => false
    t.string   "KodeJenis",   :limit => 2
    t.string   "Jenis",       :limit => 50
    t.string   "KodeArtikel", :limit => 4
    t.string   "Artikel",     :limit => 50
    t.string   "KodeKain",    :limit => 5
    t.string   "Kain",        :limit => 50
    t.string   "Type",        :limit => 1
    t.string   "Panjang",     :limit => 3
    t.string   "Lebar",       :limit => 3
  end

  create_table "tbcabppb", :id => false, :force => true do |t|
    t.string   "NoPPB",        :limit => 30,  :null => false
    t.string   "NoSO",         :limit => 50,  :null => false
    t.string   "AsalSO",       :limit => 25,  :null => false
    t.datetime "TglSO",                       :null => false
    t.string   "KodeCustomer", :limit => 10,  :null => false
    t.string   "AlamatKirim",  :limit => 200, :null => false
    t.datetime "TglPPB",                      :null => false
    t.datetime "TglKirim",                    :null => false
    t.string   "StatusPPB",    :limit => 1,   :null => false
    t.string   "UserInput",    :limit => 20,  :null => false
    t.string   "WaktuInput",   :limit => 50,  :null => false
    t.integer  "Roda",                        :null => false
    t.integer  "Stabil",                      :null => false
    t.integer  "printed"
    t.string   "Keterangan",   :limit => 100
  end

  create_table "tbcabppbdetail", :id => false, :force => true do |t|
    t.string  "NoPPB",       :limit => 30,  :null => false
    t.string  "KodeBrg",     :limit => 25,  :null => false
    t.string  "NamaBrg",     :limit => 500, :null => false
    t.string  "KodeKain",    :limit => 20,  :null => false
    t.string  "NamaKain",    :limit => 50,  :null => false
    t.integer "Panjang",                    :null => false
    t.integer "Lebar",                      :null => false
    t.integer "QtyPPBAwal",                 :null => false
    t.integer "QtyPPBKirim",                :null => false
    t.integer "QtyPPBSisa",                 :null => false
    t.integer "RStock",                     :null => false
    t.string  "Satuan",      :limit => 5,   :null => false
    t.string  "Bonus",       :limit => 10,  :null => false
    t.string  "Keterangan"
    t.string  "Status",      :limit => 1,   :null => false
    t.string  "Flag",        :limit => 1
    t.string  "idPemutihan", :limit => 30
    t.integer "Qty"
  end

  create_table "tbcabso", :id => false, :force => true do |t|
    t.string   "NoSO",         :limit => 50,  :null => false
    t.string   "NoPO",         :limit => 50,  :null => false
    t.string   "IdCabang",     :limit => 3,   :null => false
    t.string   "AsalSO",       :limit => 25,  :null => false
    t.string   "KodeCustomer", :limit => 10,  :null => false
    t.string   "KodePameran",  :limit => 20,  :null => false
    t.datetime "TglSO",                       :null => false
    t.datetime "TglDelivery"
    t.string   "KodeSales",    :limit => 10,  :null => false
    t.string   "AlamatKirim",  :limit => 200, :null => false
    t.string   "StatusSO",     :limit => 2,   :null => false
    t.string   "KeteranganSO", :limit => 100, :null => false
    t.float    "JmlDP",                       :null => false
    t.integer  "JmlHrKredit",                 :null => false
    t.string   "StatusBayar",  :limit => 1,   :null => false
    t.string   "JnsKartu",     :limit => 50,  :null => false
    t.string   "NoKartu",      :limit => 30,  :null => false
    t.string   "AtasNama",     :limit => 30,  :null => false
    t.string   "NoMerchant",   :limit => 50,  :null => false
    t.string   "PPN",          :limit => 1,   :null => false
    t.float    "JmlSumBruto",                 :null => false
    t.float    "JmlSumDiskon",                :null => false
    t.float    "JmlSumPPn",                   :null => false
    t.float    "JmlSumNetto",                 :null => false
    t.string   "UserInput",    :limit => 20
    t.string   "WaktuInput",   :limit => 50
    t.string   "NoPOGabungan"
  end

  create_table "tbcabso_a", :id => false, :force => true do |t|
    t.string   "NoSO",         :limit => 50,  :null => false
    t.string   "NoPO",         :limit => 50,  :null => false
    t.string   "IdCabang",     :limit => 3,   :null => false
    t.string   "AsalSO",       :limit => 25,  :null => false
    t.string   "KodeCustomer", :limit => 10,  :null => false
    t.string   "KodePameran",  :limit => 20,  :null => false
    t.datetime "TglSO",                       :null => false
    t.datetime "TglDelivery"
    t.string   "KodeSales",    :limit => 10,  :null => false
    t.string   "AlamatKirim",  :limit => 200, :null => false
    t.string   "StatusSO",     :limit => 2,   :null => false
    t.string   "KeteranganSO", :limit => 100, :null => false
    t.float    "JmlDP",                       :null => false
    t.integer  "JmlHrKredit",                 :null => false
    t.string   "StatusBayar",  :limit => 1,   :null => false
    t.string   "JnsKartu",     :limit => 50,  :null => false
    t.string   "NoKartu",      :limit => 30,  :null => false
    t.string   "AtasNama",     :limit => 30,  :null => false
    t.string   "NoMerchant",   :limit => 50,  :null => false
    t.string   "PPN",          :limit => 1,   :null => false
    t.float    "JmlSumBruto",                 :null => false
    t.float    "JmlSumDiskon",                :null => false
    t.float    "JmlSumPPn",                   :null => false
    t.float    "JmlSumNetto",                 :null => false
    t.string   "UserInput",    :limit => 20
    t.string   "WaktuInput",   :limit => 50
    t.string   "NoPOGabungan"
  end

  create_table "tbcabsobonus", :id => false, :force => true do |t|
    t.integer "idBonus",               :null => false
    t.string  "NoSO",    :limit => 50, :null => false
    t.string  "KodeBrg", :limit => 25, :null => false
    t.integer "Qty",                   :null => false
  end

  create_table "tbcabsodetail", :id => false, :force => true do |t|
    t.string  "NoSO",        :limit => 50, :null => false
    t.string  "KodeBrg",     :limit => 25, :null => false
    t.integer "QtyOrder",                  :null => false
    t.integer "QtyOrdering"
    t.integer "FStock",                    :null => false
    t.integer "RStock",                    :null => false
    t.integer "BkPPB",                     :null => false
    t.integer "PPB"
    t.integer "PBJ"
    t.string  "StatusSO",    :limit => 2
    t.string  "Satuan",      :limit => 5,  :null => false
    t.float   "PriceList"
    t.float   "PriceBruto"
    t.float   "Disc1"
    t.float   "Disc2"
    t.float   "PriceNetto"
    t.string  "Bonus",       :limit => 10, :null => false
    t.string  "NoPBJ",       :limit => 50
    t.string  "Tambahan",    :limit => 10
    t.string  "Keterangan"
    t.string  "idPemutihan", :limit => 30
  end

  create_table "tbcabsodetail2", :id => false, :force => true do |t|
    t.string  "NoSO",           :limit => 50, :null => false
    t.string  "KodeBrg",        :limit => 25, :null => false
    t.integer "QtyOrder",                     :null => false
    t.integer "FStock",                       :null => false
    t.integer "RStock",                       :null => false
    t.integer "BkPPB",                        :null => false
    t.integer "PPB"
    t.integer "PBJ"
    t.string  "StatusSO",       :limit => 2
    t.string  "Satuan",         :limit => 5,  :null => false
    t.float   "PriceList"
    t.float   "PriceBruto"
    t.float   "Disc1"
    t.float   "Disc2"
    t.float   "PriceNetto"
    t.string  "Bonus",          :limit => 10, :null => false
    t.string  "NoPBJ",          :limit => 50
    t.string  "Keterangan"
    t.integer "BuffStock"
    t.integer "OutstandSO"
    t.integer "OutstandPBJ"
    t.integer "OutstandPraPBJ"
    t.string  "idPemutihan",    :limit => 30
    t.string  "NoPP",           :limit => 50
  end

  create_table "tbcabsodetail2_a", :id => false, :force => true do |t|
    t.string  "NoSO",           :limit => 50, :null => false
    t.string  "KodeBrg",        :limit => 25, :null => false
    t.integer "QtyOrder",                     :null => false
    t.integer "FStock",                       :null => false
    t.integer "RStock",                       :null => false
    t.integer "BkPPB",                        :null => false
    t.integer "PPB"
    t.integer "PBJ"
    t.string  "StatusSO",       :limit => 2
    t.string  "Satuan",         :limit => 5,  :null => false
    t.float   "PriceList"
    t.float   "PriceBruto"
    t.float   "Disc1"
    t.float   "Disc2"
    t.float   "PriceNetto"
    t.string  "Bonus",          :limit => 10, :null => false
    t.string  "NoPBJ",          :limit => 50
    t.string  "Keterangan"
    t.integer "BuffStock"
    t.integer "OutstandSO"
    t.integer "OutstandPBJ"
    t.integer "OutstandPraPBJ"
    t.string  "idPemutihan",    :limit => 30
    t.string  "NoPP",           :limit => 50
  end

  create_table "tbcabsodetail_a", :id => false, :force => true do |t|
    t.string  "NoSO",        :limit => 50, :null => false
    t.string  "KodeBrg",     :limit => 25, :null => false
    t.integer "QtyOrder",                  :null => false
    t.integer "QtyOrdering"
    t.integer "FStock",                    :null => false
    t.integer "RStock",                    :null => false
    t.integer "BkPPB",                     :null => false
    t.integer "PPB"
    t.integer "PBJ"
    t.string  "StatusSO",    :limit => 2
    t.string  "Satuan",      :limit => 5,  :null => false
    t.float   "PriceList"
    t.float   "PriceBruto"
    t.float   "Disc1"
    t.float   "Disc2"
    t.float   "PriceNetto"
    t.string  "Bonus",       :limit => 10, :null => false
    t.string  "NoPBJ",       :limit => 50
    t.string  "Tambahan",    :limit => 10
    t.string  "Keterangan"
    t.string  "idPemutihan", :limit => 30
  end

  create_table "tbcustomer", :id => false, :force => true do |t|
    t.string   "Kode",              :limit => 10,                                 :null => false
    t.string   "Customer",          :limit => 50
    t.string   "Alamat1"
    t.string   "Alamat2"
    t.string   "Alamat3"
    t.string   "Kota",              :limit => 50
    t.string   "Kota2",             :limit => 50
    t.string   "Kota3",             :limit => 50
    t.string   "KoPos",             :limit => 50
    t.string   "KoPos2",            :limit => 50
    t.string   "KoPos3",            :limit => 50
    t.boolean  "PKP"
    t.string   "NPWP",              :limit => 30
    t.string   "Telp",              :limit => 30
    t.string   "Telp2",             :limit => 30
    t.string   "Telp3",             :limit => 30
    t.string   "Fax",               :limit => 20
    t.string   "Fax2",              :limit => 20
    t.string   "Fax3",              :limit => 20
    t.string   "Email",             :limit => 50
    t.string   "Jenis",             :limit => 10
    t.string   "ContactPerson"
    t.string   "ContactPerson2"
    t.string   "ContactPerson3"
    t.integer  "Lama"
    t.string   "Ket",               :limit => 100
    t.string   "IdTipeBayar",       :limit => 5
    t.string   "Account",           :limit => 10
    t.decimal  "Deposit",                          :precision => 19, :scale => 4
    t.string   "MtUang",            :limit => 10
    t.string   "Message",           :limit => 50
    t.string   "Salesman",          :limit => 10
    t.string   "GrupCode",          :limit => 10
    t.string   "HoldCode",          :limit => 1
    t.float    "CreditLimit"
    t.string   "CreditCode",        :limit => 1
    t.string   "CreditType",        :limit => 1
    t.string   "BackOrder",         :limit => 1
    t.string   "PartialShip",       :limit => 1
    t.integer  "ShipLeadTime"
    t.string   "WarehouseCode",     :limit => 10
    t.float    "Disc1",             :limit => 24
    t.float    "Disc2",             :limit => 24
    t.float    "Disc3",             :limit => 24
    t.string   "Teritory",          :limit => 10
    t.datetime "ExpireDate"
    t.string   "IDCabang",          :limit => 20
    t.integer  "topCust"
    t.integer  "Aktif"
    t.string   "TokoPusat"
    t.string   "NamaPemilik"
    t.string   "StatusKepemilikan"
    t.string   "Lampiran",          :limit => 100
    t.string   "NamaSuami",         :limit => 100
    t.string   "TlpSuami",          :limit => 50
    t.string   "TglLahirSuami",     :limit => 50
    t.string   "NamaIstri",         :limit => 100
    t.string   "TlpIstri",          :limit => 50
    t.string   "TglLahirIstri",     :limit => 50
    t.string   "nmBank1",           :limit => 100
    t.string   "kotaBank1",         :limit => 50
    t.string   "rekBank1",          :limit => 50
    t.string   "anBank1",           :limit => 100
    t.string   "nmBank2",           :limit => 100
    t.string   "kotaBank2",         :limit => 50
    t.string   "rekBank2",          :limit => 50
    t.string   "anBank2",           :limit => 100
    t.string   "nmBank3",           :limit => 100
    t.string   "kotaBank3",         :limit => 50
    t.string   "rekBank3",          :limit => 50
    t.string   "anBank3",           :limit => 100
    t.string   "KategoriCust",      :limit => 10
    t.datetime "tanggal"
    t.string   "showroom",          :limit => 2
    t.string   "sogo",              :limit => 1
  end

  create_table "tbidcabang", :primary_key => "IdCabang", :force => true do |t|
    t.string "Cabang",  :limit => 100
    t.string "Alamat1", :limit => 200
    t.string "Alamat2", :limit => 200
    t.string "Alias",   :limit => 7
  end

  create_table "tbimportdcabang", :id => false, :force => true do |t|
    t.string    "id",                  :limit => 50,                                                  :null => false
    t.string    "idcabang",            :limit => 5,                                  :default => "-"
    t.datetime  "tanggal"
    t.string    "nobukti",             :limit => 50,                                 :default => "-"
    t.string    "nosj",                :limit => 50,                                 :default => "-"
    t.datetime  "tanggalsj"
    t.string    "nofaktur",            :limit => 50,                                 :default => "-"
    t.string    "noso",                :limit => 50,                                 :default => "-"
    t.string    "customer",            :limit => 200,                                :default => "-"
    t.string    "alamatkirim",                                                       :default => "-"
    t.string    "salesman",            :limit => 50,                                 :default => "-"
    t.string    "kodebrg",             :limit => 50,                                 :default => "-"
    t.string    "namabrg",                                                           :default => "-"
    t.string    "jenisbrgdisc",        :limit => 50,                                 :default => "-"
    t.string    "kodejenis",           :limit => 5
    t.string    "jenisbrg",            :limit => 50,                                 :default => "-"
    t.string    "kodeartikel",         :limit => 8,                                  :default => "-"
    t.string    "namaartikel",                                                       :default => "-"
    t.string    "kodekain",            :limit => 10,                                 :default => "-"
    t.string    "namakain"
    t.string    "panjang",             :limit => 5,                                  :default => "-"
    t.string    "lebar",               :limit => 5,                                  :default => "-"
    t.integer   "jumlah",                                                            :default => 0
    t.string    "satuan",              :limit => 5,                                  :default => "-"
    t.decimal   "hargasatuan",                        :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "hargabruto",                         :precision => 19, :scale => 4, :default => 0.0
    t.float     "diskon1",                                                           :default => 0.0
    t.float     "diskon2",                                                           :default => 0.0
    t.float     "diskon3",                                                           :default => 0.0
    t.float     "diskon4",                                                           :default => 0.0
    t.float     "diskon5",                                                           :default => 0.0
    t.decimal   "diskonsum",                          :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "diskonrp",                           :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "harganetto1",                        :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "harganetto2",                        :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "totalnetto1",                        :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "totalnetto2",                        :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "totalnettofaktur",                   :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "totalnettofakturLA",                 :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "totalnettofakturOK",                 :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "totalnettofakturOK2",                :precision => 19, :scale => 4, :default => 0.0
    t.string    "bonus",               :limit => 10,                                 :default => "-"
    t.datetime  "tanggalkirim"
    t.string    "statusbayar",         :limit => 2,                                  :default => "-"
    t.datetime  "tanggaljatuhtempo"
    t.integer   "lamabayar",                                                         :default => 0
    t.string    "tipebarang",          :limit => 2,                                  :default => "-"
    t.string    "kodesales",           :limit => 10,                                 :default => "-"
    t.string    "kodecust",            :limit => 20,                                 :default => "-"
    t.string    "kodepameran",         :limit => 20,                                 :default => "-"
    t.string    "pameran",                                                           :default => "-"
    t.datetime  "tanggalpameran1"
    t.datetime  "tanggalpameran2"
    t.string    "idtrans",             :limit => 20,                                 :default => "-"
    t.string    "nopo",                :limit => 50,                                 :default => "-"
    t.string    "username",            :limit => 50
    t.timestamp "tanggalImport"
    t.decimal   "nupgrade",                           :precision => 19, :scale => 4, :default => 0.0
    t.decimal   "nettoupgrade",                       :precision => 19, :scale => 4, :default => 0.0
    t.string    "ketppb",                                                            :default => "-"
    t.string    "namabrand",           :limit => 100,                                :default => "-"
  end

  add_index "tbimportdcabang", ["id"], :name => "FK_tbImportCabang_tbImportMCabang"

  create_table "tbimportmcabang", :force => true do |t|
    t.timestamp "tanggal"
    t.string    "username", :limit => 50
    t.string    "komputer", :limit => 50
  end

  create_table "tbjenisbrgdisc", :id => false, :force => true do |t|
    t.string "idjenisbrgdisc", :limit => 10, :null => false
    t.string "nmjenisbrgdisc", :limit => 50
  end

  create_table "tblaporancabang", :id => false, :force => true do |t|
    t.string   "idcabang",            :limit => 5
    t.string   "nosj",                :limit => 50
    t.datetime "tanggalsj"
    t.datetime "tanggalfaktur"
    t.string   "nofaktur",            :limit => 50
    t.string   "noso",                :limit => 50
    t.string   "customer",            :limit => 200
    t.string   "alamatkirim"
    t.string   "salesman",            :limit => 50
    t.string   "kodebrg",             :limit => 50
    t.string   "namabrg"
    t.string   "jenisbrgdisc",        :limit => 50
    t.string   "kodejenis",           :limit => 5
    t.string   "jenisbrg",            :limit => 50
    t.string   "kodeartikel",         :limit => 8
    t.string   "namaartikel"
    t.string   "kodekain",            :limit => 10
    t.string   "namakain"
    t.string   "panjang",             :limit => 5
    t.string   "lebar",               :limit => 5
    t.integer  "jumlah"
    t.string   "satuan",              :limit => 5
    t.decimal  "hargasatuan",                        :precision => 19, :scale => 4
    t.decimal  "hargabruto",                         :precision => 19, :scale => 4
    t.decimal  "diskon1",                            :precision => 18, :scale => 0
    t.decimal  "diskon2",                            :precision => 18, :scale => 0
    t.decimal  "diskon3",                            :precision => 18, :scale => 0
    t.decimal  "diskon4",                            :precision => 18, :scale => 0
    t.decimal  "diskon5",                            :precision => 18, :scale => 0
    t.decimal  "diskonsum",                          :precision => 19, :scale => 4
    t.decimal  "diskonrp",                           :precision => 19, :scale => 4
    t.decimal  "harganetto1",                        :precision => 19, :scale => 4
    t.decimal  "harganetto2",                        :precision => 19, :scale => 4
    t.decimal  "totalnetto1",                        :precision => 19, :scale => 4
    t.decimal  "totalnetto2",                        :precision => 19, :scale => 4
    t.decimal  "totalnettofaktur",                   :precision => 19, :scale => 4
    t.decimal  "totalnettofakturLA",                 :precision => 19, :scale => 4
    t.decimal  "totalnettofakturOK",                 :precision => 19, :scale => 4
    t.decimal  "totalnettofakturOK2",                :precision => 19, :scale => 4
    t.string   "bonus",               :limit => 10
    t.datetime "tanggalkirim"
    t.string   "statusbayar",         :limit => 2
    t.datetime "tanggaljatuhtempo"
    t.integer  "lamabayar"
    t.string   "tipebarang",          :limit => 2
    t.string   "kodesales",           :limit => 10
    t.string   "kodecust",            :limit => 20
    t.string   "kodepameran",         :limit => 20
    t.string   "pameran"
    t.string   "idtrans",             :limit => 20
    t.string   "nopo",                :limit => 50
    t.decimal  "nupgrade",                           :precision => 19, :scale => 4
    t.decimal  "nettoupgrade",                       :precision => 19, :scale => 4
    t.string   "ketppb"
    t.string   "namabrand",           :limit => 100
    t.datetime "tanggalinput"
  end

  create_table "tbstockcabang", :id => false, :force => true do |t|
    t.datetime "tanggal",                       :null => false
    t.string   "cabang",         :limit => 2,   :null => false
    t.string   "kodebrg",        :limit => 30,  :null => false
    t.string   "namabrg",        :limit => 100
    t.integer  "freestock"
    t.integer  "bufferstock"
    t.integer  "outstandingSO"
    t.integer  "outstandingPBJ"
  end

  create_table "testing", :id => false, :force => true do |t|
    t.string "kodebrg", :limit => 50
    t.string "namabrg"
  end

  create_table "will_filter_filters", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "data"
    t.integer  "user_id"
    t.string   "model_class_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "will_filter_filters", ["user_id"], :name => "index_will_filter_filters_on_user_id"

end
