#= Pdf::CargoWorkerBasePdfを継承
#配番表（実績）PDF作成クラス  Numbering list (actual results) PDF creation class
class Pdf::CargoWorkerResultPdf < Pdf::CargoWorkerBasePdf
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
        if cargo_request = cargo.cargo_request
          dr_sum = %i(fm_m dm_m wm_m cr_m ld_m ld_s bh_m bh_s sl_m sl_s bl_m bl_s lf_m lf_s sc_m sc_s tl_m tl_s ot_m).map{|sym| cargo_request[sym]}.compact.sum
          wk_sum = %i(hd_w db_w hs_w sn_w eg_w ot_w).map{|sym| cargo_request[sym]}.compact.sum
          sum = dr_sum + wk_sum
          tmp_ary[10], tmp_ary[11], tmp_ary[12] = [dr_sum, wk_sum, sum].map { |s| s.zero? ? "" : s.to_s }
        end
        if cargo_workers = cargo.result_cargo_worker.to_a
          tmp_ary[13] = cargo_workers.map{|cw| cw[:user_id]}.filter{|user_id| user_id.to_i!=0}.uniq.length
          # UAT183 「労供」欄の入力値を使用 UAT183 Use input value in “Labor” field
          tmp_ary[14] = cargo.rk_np.to_i # 臨時作業員列 Temporary worker column
          tmp_ary[15] = tmp_ary[13] + tmp_ary[14]
          (13..15).each{|num| tmp_ary[num] = tmp_ary[num].zero? ? "" : tmp_ary[num].to_s}
        end
        ret_ary << tmp_ary
      end
      table_data
    end
    daily_table_data
  end
end

