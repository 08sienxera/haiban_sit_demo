class CargoMaster < ApplicationRecord
    extend Common::Func
    default_scope {where(:deleted_at => nil)}
    # 集計カテゴリリスト Aggregate category list
    AggregateCategories=[["集計なし","0"],["港湾運送","1"],["倉庫","2"],["代理店","3"]]

    #===入力画面フォームの生成 Generation of input screen form
    def self.set_input_form(key)
        form = Common::CommonClass.new(key)
        form.setparams("move_no",{"title"=>self.human_attribute_name(:move_no),"type"=>"textA",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
        form.setparams("work_name",{"title"=>self.human_attribute_name(:work_name),"type"=>"textJ",'size'=>"40","maxlength"=>"32","inputFlg"=>1,"essFlg"=>1,"align"=>"L"})
        form.setparams("work_place",{"title"=>self.human_attribute_name(:work_place),"type"=>"textJ",'size'=>"20","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L"})
        form.setparams("aggregate_category",{"title"=>self.human_attribute_name(:aggregate_category),"type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>AggregateCategories})
        form.setparams("cargo_class",{"title"=>self.human_attribute_name(:cargo_class),"type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>CargoClassMaster.all.pluck(:name,:cargo_class)})
        # form.setparams("cargo_class",{"title"=>self.human_attribute_name(:cargo_class),"type"=>"select",'size'=>"9","maxlength"=>"8","inputFlg"=>1,"essFlg"=>0,"align"=>"L","list"=>CargoClasses})
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
        form.setparam('move_no','link',{:action=>:edit,:id=>'id'})
        return form
    end
end
