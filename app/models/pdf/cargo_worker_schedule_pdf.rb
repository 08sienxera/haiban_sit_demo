#= Pdf::CargoWorkerBasePdfを継承
#配番表（予定）PDF作成クラス  Numbering list (planned) PDF creation class
class Pdf::CargoWorkerSchedulePdf < Pdf::CargoWorkerBasePdf
  private
  def convert_table_data(daily_cargo_list,rel_data,col_size)
    return {} if daily_cargo_list.blank?
    daily_table_data = daily_cargo_list.transform_values do |cargos|
      table_data = cargos.each_with_object([]) do |cargo,ret_ary|
        tmp_ary = Array.new(col_size,"")
        tmp_ary[0] = cargo[:work_date].strftime("%Y/%m/%d")
        tmp_ary[1] = cargo[:work_no].to_s
        tmp_ary[2] = cargo[:work_name]
        tmp_ary[3] = rel_data[:cargo_cd_names][cargo[:work_cd]] || ""
        tmp_ary[4] = cargo[:cargo_name]
        tmp_ary[6] = cargo[:work_place]
        
        tmp_ary[7] = cargo[:s_time]&.strftime("%H:%M") || ""
        tmp_ary[8] = cargo[:e_time]&.strftime("%H:%M") || ""
        tmp_ary[9] = cargo[:machine_nm]
        dr_sum = %i(fm_m dm_m wm_m cr_m ld_m ld_s bh_m bh_s sl_m sl_s bl_m bl_s lf_m lf_s sc_m sc_s tl_m tl_s ot_m).map{|sym| cargo[sym]}.compact.sum
        wk_sum = %i(hd_w db_w hs_w sn_w eg_w ot_w).map{|sym| cargo[sym]}.compact.sum
        sum = dr_sum + wk_sum
        tmp_ary[10], tmp_ary[11], tmp_ary[12] = [dr_sum, wk_sum, sum].map { |s| s.zero? ? "" : s.to_s }
        ret_ary << tmp_ary
      end
      table_data
    end
    daily_table_data
  end
end