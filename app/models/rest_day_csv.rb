# coding: utf-8
require 'nkf'
require 'csv'
require 'mime/types'
class RestDayCsv
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  DAY_COLUMN = 0
  DESCRIPTION_COLUMN = 1
  WORK_DAY_TYPE = 2 #default 0 for rest day, 1 for work day

  attr_accessor :file
  attr_accessor :headers, :data_rows

  validate :check_file_format
  validates :file, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def import_from_csv!
    io_string = NKF.nkf('-w', self.file.read)

    line_num = 1
    ActiveRecord::Base.transaction do
      CSV.parse(io_string) do |row|
        RestDay.create!(:day => row[DAY_COLUMN], :description => row[DESCRIPTION_COLUMN], :work_type => row[WORK_DAY_TYPE])
        line_num += 1
      end
    end

  rescue => e
    Rails.logger.warn("import_from_csv error.")
    Rails.logger.warn(e)
    raise "CSV読み込みエラー: #{line_num}行目でエラーが発生しました"
  end

  private
  def check_file_format
    errors.add(:file, :invalid) unless MIME::Types.type_for(self.file.original_filename).include?('text/csv')
  end
end
