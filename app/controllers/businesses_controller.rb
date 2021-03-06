class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]

  # GET /businesses
  # GET /businesses.json
  def index
    # @businesses = Business.all
    if params.has_key?(:service)
      @businesses = []
      @services = Service.where(service_type: params[:service])
      business_ids = @services.map {|service| service.business_id }
      found_businesses = business_ids.map {|id| Business.find(id) }
      # @businesses = found_businesses

      # ORIGINAL CODE ABOVE
      businesses_with_appts = found_businesses.select {|business| business.appointments.length > 0}
      bizzes_with_avail_appts = []
      businesses_with_appts.each do |business|
        business.appointments.each do |appt|
          if appt.booked == false && appt.within_two_days? && !bizzes_with_avail_appts.include?(business)
            bizzes_with_avail_appts << appt.business_object
          end
        end
        @businesses = bizzes_with_avail_appts
      end
      render json: { businesses: @businesses }
      # END NEW CODE
    else
      @businesses = Business.all
    end
  end

  # GET /businesses/1
  # GET /businesses/1.json
    def show
    @business = Business.find_by(id: params[:id])
    @employee = Employee.find_by(business_id: @business.id)
    # render json: { employee: @employee, business: @business }
    if @business && @employee
      respond_to do |format|
        format.html
        format.json { render json: {employee: @employee, business: @business, appointments: @employee.formatted_available_appointments }}
      end
    else
      redirect_to root_url
    end
  end

  # GET /businesses/new
  def new
    @business = Business.new
  end

  # Search for query params
  def search
  end

  # GET /businesses/1/edit
  def edit
    @business = Business.find(params[:id])
    redirect_to root_url unless @business.id == session[:business_id]
  end

  # POST /businesses
  # POST /businesses.json
  def create
    @business = Business.new(business_params)
    respond_to do |format|
      if @business.save
        format.html { redirect_to @business, notice: 'Business was successfully created.' }
        format.json { render :show, status: :created, location: @business }
        session[:business_id] = @business.id
      else
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /businesses/1
  # PATCH/PUT /businesses/1.json
  def update
    respond_to do |format|
      if @business.update(business_params)
        format.html { redirect_to @business, notice: 'Business was successfully updated.' }
        format.json { render :show, status: :ok, location: @business }
      else
        format.html { render :edit }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    redirect_to root_url unless @business.id == session[:business_id]

    @business.destroy
    respond_to do |format|
      format.html { redirect_to businesses_url, notice: 'Business was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_business
      @business = Business.find_by(id: params[:id])
    end

    def business_params
      params.require(:business).permit(:business_name, :address, :open_at, :close_at, :lat, :long, :password, :email)
    end
end
