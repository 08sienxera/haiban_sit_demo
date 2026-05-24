# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
MY_NAME = "seeds"
GApplicable = "2005/06/16"
UApplicable = "2024/03/16"
#
#===改定日 | Revision date
p "applicable"
[
    {:section=>1,:applicable=>"2004/06/01"},
    {:section=>1,:applicable=>GApplicable},
    {:section=>2,:applicable=>"2024/01/11"},
    {:section=>2,:applicable=>UApplicable},
].each{|data|Applicable.create_data([:section,:applicable],data,MY_NAME,true)}

#=== 部署 | Department
p "branches"
[
    {:applicable=>GApplicable,:cd=>"1",:name=>"１-１",:color=>"#ffffc6",:desp_index=>"1"},
    {:applicable=>GApplicable,:cd=>"2",:name=>"１-２",:color=>"#ffc6c6",:desp_index=>"2"},
    {:applicable=>GApplicable,:cd=>"3",:name=>"２-１",:color=>"#c6e2ff",:desp_index=>"3"},
    {:applicable=>GApplicable,:cd=>"4",:name=>"２-２",:color=>"#c6ffc6",:desp_index=>"4"},
    {:applicable=>GApplicable,:cd=>"5",:name=>"作 業",:color=>"",:desp_index=>"5"},
    {:applicable=>GApplicable,:cd=>"6",:name=>"事 務",:color=>"",:desp_index=>"6"},
].each{|data|Branche.create_data([:applicable,:cd],data,MY_NAME,true)}

#=== 掲示-公開対象グループ | Bulletin board - Public target group
p "board_groups"
[
    {:name=>"全員",:desp_index=>1,:group_type=>"all"},
    {:name=>"１課",:desp_index=>2,:group_type=>"10"},
    {:name=>"１課１係",:desp_index=>3,:group_type=>"1"},
    {:name=>"１課２係",:desp_index=>4,:group_type=>"2"},
    {:name=>"２課",:desp_index=>5,:group_type=>"20"},
    {:name=>"２課１係",:desp_index=>6,:group_type=>"3"},
    {:name=>"２課２係",:desp_index=>7,:group_type=>"4"},
].each{|data|BoardGroup.create_data(:id,data,MY_NAME,true)}
#
#=== ユーザマスタ | User master
p "users"
[
    {:login_id=>"xadmin",:name=>"正興管理者",:password=>"admin",
     :bbs_max_count=>10,:bbs_mail_flg=>2,:holiday_mail_flg=>1,:mail=>"08sienxera@gmail.com",
     :tel=>"03-5835-1012",:auth_flg=>5},
].each{|data|User.create_data(:login_id,data,MY_NAME,true)}