#= Pdf::CargoCommonPdfを継承
#配番人数表PDF作成クラス
class Pdf::CargoHeadCountPdf < Pdf::CargoCommonPdf
  #初期設定
  def initialize(cd,page_condition = {})
    @title = "配 番 人 数 表"
    @title_under_line_width = 200
    super(cd,page_condition)
  end
end

