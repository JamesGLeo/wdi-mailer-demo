class LemursController < ApplicationController
  before_action :set_lemur, only: [:show, :edit, :update, :destroy]

  # GET /lemurs
  # GET /lemurs.json
  def index
    @lemurs = Lemur.all
  end

  # GET /lemurs/1
  # GET /lemurs/1.json
  def show
  end

  # GET /lemurs/new
  def new
    @lemur = Lemur.new
  end

  # GET /lemurs/1/edit
  def edit
  end

  # POST /lemurs
  # POST /lemurs.json
  def create
    @lemur = Lemur.new(lemur_params)

    respond_to do |format|
      if @lemur.save

        LemurMailer.delay.welcome_lemur(@lemur)

        format.html { redirect_to @lemur, notice: 'Lemur was successfully created.' }
        format.json { render :show, status: :created, location: @lemur }
      else
        format.html { render :new }
        format.json { render json: @lemur.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lemurs/1
  # PATCH/PUT /lemurs/1.json
  def update
    respond_to do |format|
      if @lemur.update(lemur_params)
        format.html { redirect_to @lemur, notice: 'Lemur was successfully updated.' }
        format.json { render :show, status: :ok, location: @lemur }
      else
        format.html { render :edit }
        format.json { render json: @lemur.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lemurs/1
  # DELETE /lemurs/1.json
  def destroy
    @lemur.destroy
    respond_to do |format|
      format.html { redirect_to lemurs_url, notice: 'Lemur was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lemur
      @lemur = Lemur.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lemur_params
      params.require(:lemur).permit(:name, :email)
    end
end
