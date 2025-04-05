class ImagesController < ApplicationController
  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
  
    # タイトルが送られてこなかった場合、自動的に設定。後々タイトル入力させる様にするかも
    @image.title ||= "無題画像 - #{Time.current.strftime('%Y%m%d%H%M%S')}"
  
    if @image.save
      redirect_to @image
    else
      render :new, status: :unprocessable_entity
    end
  end
  

  def show
    @image = Image.find(params[:id])
  end

  private

  def image_params
    params.require(:image).permit(:file, :title)
  end
end
