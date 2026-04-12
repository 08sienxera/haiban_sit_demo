class AddCompetenceCaToWokers < ActiveRecord::Migration[7.1]
  def change
    add_column :wokers ,:competence_ca, :integer, :limit =>1
    add_column :wokers ,:competence_tl, :integer, :limit =>1
    con = ActiveRecord::Base.connection
    con.execute("update wokers set competence_ca=-1,competence_tl=-1")
  end
end
