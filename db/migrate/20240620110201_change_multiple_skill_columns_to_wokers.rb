class ChangeMultipleSkillColumnsToWokers < ActiveRecord::Migration[7.1]
  def change
    add_column :wokers ,:competence_fmm, :integer, :limit =>1
    add_column :wokers ,:competence_fmc, :integer, :limit =>1
    add_column :wokers ,:competence_fma, :integer, :limit =>1
    add_column :wokers ,:competence_fmp, :integer, :limit =>1
    add_column :wokers ,:competence_sn, :integer, :limit =>1
    add_column :wokers ,:competence_od, :integer, :limit =>1
    add_column :wokers ,:competence_cc, :integer, :limit =>1
    add_column :wokers ,:competence_em, :integer, :limit =>1
    add_column :wokers ,:competence_ep, :integer, :limit =>1
    add_column :wokers ,:competence_cr3, :integer, :limit =>1
    add_column :wokers ,:competence_cr5, :integer, :limit =>1
    add_column :wokers ,:competence_cr6, :integer, :limit =>1
    add_column :wokers ,:competence_cr7, :integer, :limit =>1
    add_column :wokers ,:competence_cru, :integer, :limit =>1
    add_column :wokers ,:competence_wwm, :integer, :limit =>1
    add_column :wokers ,:competence_crg, :integer, :limit =>1
    add_column :wokers ,:competence_scm, :integer, :limit =>1
    add_column :wokers ,:competence_scc, :integer, :limit =>1
    add_column :wokers ,:competence_tlm, :integer, :limit =>1
    add_column :wokers ,:competence_tlc, :integer, :limit =>1
    add_column :wokers ,:competence_lfl, :integer, :limit =>1
    add_column :wokers ,:competence_ldc, :integer, :limit =>1
    add_column :wokers ,:competence_ldm, :integer, :limit =>1
    add_column :wokers ,:competence_bhh, :integer, :limit =>1
    add_column :wokers ,:competence_bhs, :integer, :limit =>1
    add_column :wokers ,:competence_bld, :integer, :limit =>1
    add_column :wokers ,:competence_blh, :integer, :limit =>1
    add_column :wokers ,:competence_slm, :integer, :limit =>1
    add_column :wokers ,:competence_slc, :integer, :limit =>1
    add_column :wokers ,:competence_sw, :integer, :limit =>1
    add_column :wokers ,:competence_sp, :integer, :limit =>1
    add_column :wokers ,:competence_clr, :integer, :limit =>1
    add_column :wokers ,:competence_crp, :integer, :limit =>1
    add_column :wokers ,:competence_cre, :integer, :limit =>1
    add_column :wokers ,:competence_crs, :integer, :limit =>1
    add_column :wokers ,:competence_w3, :integer, :limit =>1
    add_column :wokers ,:competence_s5, :integer, :limit =>1
    add_column :wokers ,:competence_s7, :integer, :limit =>1
    add_column :wokers ,:competence_wgd, :integer, :limit =>1
    add_column :wokers ,:competence_wal, :integer, :limit =>1
    add_column :wokers ,:competence_w6e, :integer, :limit =>1
    add_column :wokers ,:competence_wbg, :integer, :limit =>1
    add_column :wokers ,:competence_wsm, :integer, :limit =>1
    add_column :wokers ,:competence_wsc, :integer, :limit =>1
    add_column :wokers ,:competence_wc, :integer, :limit =>1
    add_column :wokers ,:competence_wcc, :integer, :limit =>1
    add_column :wokers ,:competence_wlg, :integer, :limit =>1
    add_column :wokers ,:competence_mt, :integer, :limit =>1
    remove_column :wokers ,:competence_fm
    remove_column :wokers ,:competence_wm
    remove_column :wokers ,:competence_cr
    remove_column :wokers ,:competence_ld
    remove_column :wokers ,:competence_bh
    remove_column :wokers ,:competence_sl
    remove_column :wokers ,:competence_bl
    remove_column :wokers ,:competence_sc
    remove_column :wokers ,:competence_ot
    remove_column :wokers ,:competence_dv
    remove_column :wokers ,:competence_wk

  end
end
