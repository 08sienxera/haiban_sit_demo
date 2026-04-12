# coding: utf-8
#= 配番機械
class CargoMachine < ApplicationRecord
  belongs_to :cargo
  belongs_to :machine
  extend Common::Func
  default_scope {where(:deleted_at => nil)}
end
