class Image < ApplicationRecord
    has_one_attached :file
    has_one_attached :processed_file
end
