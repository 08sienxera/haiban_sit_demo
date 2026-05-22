module BoardHelper
  # 画像のプレビューを提供 Provides image preview
  def img_previous(board)
    file_paths = board.get_file_path
    return "" unless file_paths.any?{|_,path| path.present?} 

    img_tags = []
    img_size = []

    file_paths.each do |key,path|
      file_extension = board.get_file_extention(key)
      next if file_extension.blank?
      if file_extension.upcase=="PDF" # PDF
        a_tag = link_to({:action=>:file_output,:id=>board.id,:attr=>key},:style=>"text-decoration:none;") do
          imgs = board.imgs(key)
          img_size << imgs.size
          safe_join(imgs.map{|img| image_tag(img,:style=>"max-width:50%;width:__width__%;box-shadow: 0px 0px 10px #aaa;margin:3px 5px 1rem;") })
        end
        img_tags << ("<p class='file_name' style='margin:0;'>（ファイル名：#{board[key]}）</p>"+a_tag).html_safe
      elsif Board::FILE_EXTENSIONS[:image].include?(file_extension.downcase) # 画像 image
        a_tag = link_to({:action=>:file_output,:id=>board.id,:attr=>key},:style=>"text-decoration:none;") do
          imgs = [path].map{|p| p.start_with?("public/") ? p.sub(/^public/, "") : p}
          img_size << imgs.size
          safe_join(imgs.map{|img| image_tag(img,:style=>"max-width:50%;width:__width__%;box-shadow: 0px 0px 10px #aaa;margin:3px 5px 1rem;") })
        end
        img_tags << a_tag
      else
        next
      end
    end

    max_size = img_size.blank? ? 1 : img_size.max
    img_width = max_size==1 ? 49 : (100-max_size)/max_size
    html = safe_join(img_tags).gsub(/__width__/, img_width.to_s).html_safe
    html
  end

  # 添付ファイルのダウンロードリストを提供 Provides a list of downloadable attachments.
  def file_download_links(board)
    links = board.get_file_path.map do |key,path|
      content_tag(:li) do
        link_to(board[key],{:action=>:file_output,:id=>board.id,:attr=>key})
      end if path.present?
    end
    content_tag(:ul,safe_join(links))
  end
end