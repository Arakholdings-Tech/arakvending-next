class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy, :cancel, :select ]

  # GET /products or /products.json
  def index
    @products = Product.page(params[:page]).per(20)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  def select
    Vending::Transport.send_message Vending::Messages.select_buy(@product.selection)

    payment = @product.payments.create(amount: @product.price, status: "queued")

    ProcessPaymentJob.perform_later(payment)
  end

  def cancel
    Vending::Transport.send_message Vending::Messages.cancel_selection

    Esocket::Transport.send_message(Esocket::Messages.cancel_transaction(@product.payment&.transaction&.transaction_id))

    redirect_to products_path
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Machine.first.products.build(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.expect(product: [ :picture, :name, :price, :selection, :quantity ])
  end
end
