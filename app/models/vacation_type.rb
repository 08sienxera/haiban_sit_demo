class VacationType < ApplicationRecord
    extend Common::Func
    default_scope {where(:deleted_at => nil)}

    #
    #===入力画面フォームの生成 Generation of input screen form
    def self.set_input_form(key)
        # vacation_type:
        form = Common::CommonClass.new(key)
        # no: 勤怠ID Attendance ID
        form.setparams("base_no",{"title"=>self.human_attribute_name(:base_no),"type"=>"textA",'size'=>"3","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"R"})
        # cd:  勤怠コード Attendance code
        form.setparams("cd",{"title"=>self.human_attribute_name(:cd),"type"=>"textA",'size'=>"3","maxlength"=>"2","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
        # name: 配番用表記 Attendance code
        form.setparams("name",{"title"=>self.human_attribute_name(:name),"type"=>"textJ",'size'=>"10","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
        # assign_name: 配番表用表記  Notation for numbering
        form.setparams("assign_name",{"title"=>self.human_attribute_name(:assign_name),"type"=>"textJ",'size'=>"10","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
        # time_sheet_name: 出勤時間表用表記 Notation for attendance time table
        form.setparams("time_sheet_name",{"title"=>self.human_attribute_name(:time_sheet_name),"type"=>"textJ",'size'=>"10","maxlength"=>"4","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
        # form.setparams("desp_index",{"title"=>self.human_attribute_name(:desp_index),"type"=>"textA",'size'=>"3","maxlength"=>"2","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
        return form
    end
    #
    #===更新画面フォームの生成 Generate update screen form
    def self.set_edit_form(key)
        return self.set_input_form(key)
    end
    #
    #===CSVフォームの生成 Generate CSV form
    def self.set_csv_form(key)
        form = self.set_input_form(key)
        return form
    end
    #
    #===一覧画面フォームの生成 Generate list screen form
    def self.set_list_form(key)
        form = self.set_input_form(key)
        form.set_all_param("inputFlg",0)
        form.set_all_param("essFlg",0)

        form.setparams('id',{'title'=>'ID','type'=>'hidden','size'=>'20','maxlength'=>'16','inputFlg'=>0,'essFlg'=>0,'align'=>'R','noserch'=>"1"})
        form.set_index('id',0)
        form.setparam('base_no','link',{:action=>:edit,:id=>'id'})
        return form
    end



end
