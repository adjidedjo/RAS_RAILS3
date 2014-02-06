class SalesImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file

  def initialize(attributes = {})
    attributes.each { |nosj, value| send("#{nosj}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_products.map(&:valid?).all?
      imported_products.each(&:save!)
      true
    else
      imported_products.each_with_index do |product, index|
        product.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = LaporanCabang.find_by_nosj_and_kodebrg_and_customer_and_jumlah_and_cabang_id(row["nosj"],row["kodebrg"],row["customer"],row["jumlah"],row["cabang_id"]) || LaporanCabang.new
      #product = LaporanCabang.where("nofaktur like ? and kodebrg like ? and cabang_id = ?", row["nofaktur"], row["kodebrg"], row["cabang_id"]) || LaporanCabang.new
      product.attributes = row.to_hash.slice(*LaporanCabang.accessible_attributes)
      product
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
