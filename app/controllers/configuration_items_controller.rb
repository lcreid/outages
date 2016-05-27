class ConfigurationItemsController < ApplicationController
  def create
    @configuration_item = ConfigurationItem.new(configuration_item_params)

    if @configuration_item.save
      redirect_to @configuration_item
    else
      render 'new'
    end
  end

  private

  def configuration_item_params
    params.require(:configuration_item).permit(:name)
  end
end
