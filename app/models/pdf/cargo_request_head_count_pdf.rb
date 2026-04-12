#= Pdf::CargoCommonPdfを継承
#必要人数表PDF作成クラス
class Pdf::CargoRequestHeadCountPdf < Pdf::CargoCommonPdf
  #初期設定
  def initialize(cd,page_condition = {})
    @title = "必要人数表(調整用)"
    @title_under_line_width = 250
    super(cd,page_condition)
  end
end

