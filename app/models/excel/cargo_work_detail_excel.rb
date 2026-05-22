#= 荷役作業明細一覧作成クラス Cargo handling work details list creation class
class Excel::CargoWorkDetailExcel
  #初期設定 Initial settings
  def initialize(cd)
    unless File.exist?(FILE_OUT_DIR)
      Dir::mkdir(FILE_OUT_DIR,0755)
    end

    @filepath="#{FILE_OUT_DIR}/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{cd}.xls"
    @pack = Axlsx::Package.new
    @workbook = @pack.workbook
    
    
    ######################################################
    # 書式を作成 create format
    ######################################################
    #基本 basic
    @font = @workbook.styles.add_style(
      font_name: 'ＭＳ Ｐゴシック',
      sz: 11,
      # b: true,              # 太字 Bold
      alignment: { horizontal: :center }  # 水平方向に中央揃え horizontally centered
    )

    #使用方法 How to use
    # wb.add_worksheet(name: 'Styled Sheet') do |sheet|
    #   sheet.add_row ['Name', 'Age', 'City'], style: header_style  # ヘッダーにスタイルを適用
    #   sheet.add_row ['Alice', 30, 'New York']
    #   sheet.add_row ['Bob', 22, 'Los Angeles']
    #   sheet.add_row ['Charlie', 25, 'Chicago']
    # end
  end

  #Excelシートを作成、追加
  # 引数
  # sheet_name: 作成シート名
  # matrix_data: ２次元配列データ
  # style: セルスタイルを任意で指定
  # #Create and add Excel sheet 
  # argument 
  # sheet_name: name of created sheet 
  # matrix_data: 2D array data 
  # style: optionally specify cell style
  def make_excel(sheet_name,matrix_data,style:nil)
    @workbook.add_worksheet(name: sheet_name) do |sheet|
      if style
        @use_style = @workbook.styles.add_style(*style)
      else
        @use_style = @font
      end
      matrix_data.each do |row|
        sheet.add_row(row, style: @use_style)  # ヘッダーにスタイルを適用 Apply styles to header
      end
    end
  end

  #Excelを保存し後始末 Save Excel and clean up afterwards
  def fin()
    @pack.serialize(@filepath)
    @workbook=nil
    return @filepath
  end
end
