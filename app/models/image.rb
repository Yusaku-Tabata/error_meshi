class Image < ApplicationRecord
  has_one_attached :file
  has_one_attached :processed_file

  after_commit :process_image, on: [:create]

  private

  def process_image
    return unless file.attached?

    require "mini_magick"

    # 一時ファイルを加工
    downloaded = ActiveStorage::Blob.service.send(:path_for, file.blob.key)
    image = MiniMagick::Image.open(downloaded)

    # 加工内容（ここはお好みでどんどん追加できます）
    image.combine_options do |c|
      c.negate         # 色反転
      c.contrast       # コントラスト強調
      c.wave "5x80"    # 歪ませる
    end

    # 加工後のファイルを保存
    temp_path = Rails.root.join("tmp", "processed_#{SecureRandom.hex(8)}.jpg")
    image.write(temp_path)

    # ActiveStorageに添付
    processed_file.attach(io: File.open(temp_path), filename: "processed.jpg", content_type: "image/jpeg")

    # 一時ファイル削除
    File.delete(temp_path) if File.exist?(temp_path)
  end
end