class Parser::VacationCalendarExcelParser < Parser::Parser
     def initialize(*args)
        super(*args)
        @directory, @file_name = *args
    end

    def parse()
        require "roo"
        xlsx = Roo::Spreadsheet.open(resource_path)
        parse_data = {
            :file_name=>@file_name,
            :sheet_count=>xlsx.sheets.size,
            :sheets=>[]
        }
        xlsx.each_with_pagename do |name, sheet|
            data = {
                :sheet_name=>name,
                :sheet_title=>name,
                :sheet_data=>[],
                :time_stamp=>sheet.row(sheet.last_row)[0]
            }
            sheet.last_row.times do |index|
                sheet_index = index+=1
                row = sheet.row(sheet_index)
                next if row[0].blank? || row[0].include?("更新日時")
                data[:sheet_data] << sheet.row(sheet_index)
            end
            parse_data[:sheets] << data
        end
        parse_data
    end

    private 
    def resource_path
        @directory + "/" + @file_name
    end

end

