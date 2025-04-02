class Image < ApplicationRecord
  has_one_attached :file
  has_one_attached :processed_file

  after_commit :process_image, on: [:create]

  private

  def process_image
    return unless file.attached?
    require "mini_magick"
    downloaded = file.blob.download

    Tempfile.create(["original", ".jpg"]) do |tempfile|
      tempfile.binmode
      tempfile.write(downloaded)
      tempfile.rewind

      image = MiniMagick::Image.open(tempfile.path)

      # 加工内容
      image.combine_options do |c|
        c.negate         # 色反転
        c.contrast       # コントラスト強調
        c.wave "5x80"    # 歪み
      end

      # 加工後のファイルを保存
      processed_tempfile = Tempfile.new(["processed", ".jpg"])
      image.write(processed_tempfile.path)

      # ActiveStorageに添付
      processed_file.attach(
        io: File.open(processed_tempfile.path),
        filename: "processed.jpg",
        content_type: "image/jpeg"
      )

      processed_tempfile.close
      processed_tempfile.unlink
    end
  end
end