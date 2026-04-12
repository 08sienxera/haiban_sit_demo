class BoardGroup < ApplicationRecord
    extend Common::Func
    has_many :board_group_woker
    default_scope {where(:deleted_at => nil)}


    CanModGroupType = "list"
    #
    #===入力画面フォームの生成
    def self.set_input_form(key)
        form = Common::CommonClass.new(key)
        # name: グループ名称
        form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"40","maxlength"=>"32","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
        # desp_index: 表示順
        form.setparams("desp_index",{"title"=>self.human_attribute_name(:desp_index),"type"=>"textN",'size'=>"10","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"R"})
        # group_type: 対象タイプ
        form.setparams("group_type",{"title"=>self.human_attribute_name(:group_type),"type"=>"hidden",'size'=>"4","maxlength"=>"4","inputFlg"=>1,"essFlg"=>1,"align"=>"C","defVal"=>CanModGroupType})
        return form
    end
    #
    #===更新画面フォームの生成
    def self.set_edit_form(key)
        return self.set_input_form(key)
    end
    #
    #===CSVフォームの生成
    def self.set_csv_form(key)
        form = self.set_input_form(key)
        return form
    end
    #
    #===一覧画面フォームの生成
    def self.set_list_form(key)
        form = self.set_input_form(key)
        form.set_all_param("inputFlg",0)
        form.set_all_param("essFlg",0)
        form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
        form.set_index('id',0)
        form.setparam('name','link',{:action=>:edit,:id=>'id'})
        return form
    end
    #
    #=== マスタ用　更新可否を返す
    def can_mod_group_type?
        (self[:group_type] == CanModGroupType)
    end
    #
    #===掲示済みの対象者更新
    def resettting_target
        p "!!!!!!"*20
        p  "ToDo:BoardGroup.resettting_target"
    end

    #===掲示対象のユーザ一覧を取得
    def get_user_list
        case self.group_type
        when 'all'
            return User.where.not(:login_id=>'xadmin').pluck(:login_id)
        when '10'
            return Woker.get_latest.where(:branch_cd=>%w(1 2)).pluck(:login_id)
        when '1'
            return Woker.get_latest.where(:branch_cd=>'1').pluck(:login_id)
        when '2'
            return Woker.get_latest.where(:branch_cd=>'2').pluck(:login_id)
        when '20'
            return Woker.get_latest.where(:branch_cd=>%w(3 4)).pluck(:login_id)
        when '3'
            return Woker.get_latest.where(:branch_cd=>'3').pluck(:login_id)
        when '4'
            return Woker.get_latest.where(:branch_cd=>'4').pluck(:login_id)
        when 'list'
            board_group_wokers = BoardGroupWoker.where(:board_group_id=>self.id)
            if board_group_wokers
                board_group_wokers.pluck(:login_id)
            else
                []
            end
        end
    end
    

end
