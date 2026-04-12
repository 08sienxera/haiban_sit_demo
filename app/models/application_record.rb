class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  def assign_if_exists(params)
    permitted_keys = self.attribute_names
    filtered_params = params.slice(*permitted_keys)
    self.assign_attributes(filtered_params)
  end

  def self.get_indexes(table_name, &proc)
      indexes = ApplicationRecord.connection.indexes(table_name)
      if block_given?
        indexes.select!{|r| proc.call(r)}
      end
      indexes
  end

  def ck_unique()
    indexes = ApplicationRecord.get_indexes(self.class.table_name){|r| r.unique==true}
    records = []
    if indexes.present?
      indexes.each do |index|
        attributes = index.columns.map{|key|
          k = key.to_sym
          v = self[k]
          [k,v]
        }.to_h
        r = self.class.where(**attributes).where.not(:id=>self.id)
        records += r.to_a if r.present?
      end
    end
    records
  end


end
