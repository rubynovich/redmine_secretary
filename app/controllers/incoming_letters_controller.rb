class IncomingLettersController < ApplicationController
  unloadable

  def index
    @collection = IncomingLetter.all
  end

  def new
  end
  
  def show
  end

  def edit
  end

  def update
  end

  def create
  end

  def destroy
  end
end
