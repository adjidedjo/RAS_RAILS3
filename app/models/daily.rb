class Daily < ActiveRecord::Base
  set_table_name "tblaporancabang"
  attr_accessible *column_names
  
  def graph_daily(day)
    
  end
    
end
