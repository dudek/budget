class WalletsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @wallets = current_user.wallets
    redirect_to new_wallet_path, notice: t('flash.no_wallets') if @wallets.blank?
  end

  def new
    @wallet = Wallet.new
  end

  def create
    @wallet = Wallet.new(params[:wallet])
    @wallet.user = current_user
    if @wallet.save
      if current_user.wallets.count == 1
        redirect_to new_expense_path
      else
        redirect_to wallets_path, notice: t('flash.wallet_success', name: @wallet.name)
      end
    else
      render action: 'new'
    end
  end

  def edit
    @wallet = current_user.wallets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to wallets_path, notice: t('flash.no_record', model: t('activerecord.models.wallet'))
  end

  def update
    begin
      @wallet = current_user.wallets.find(params[:id])
      @wallet.attributes = params[:wallet]
      if @wallet.save
        redirect_to wallets_path, notice: t('flash.update_one', model: t('activerecord.models.wallet'))
      else
        render action: 'edit'
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to wallets_path, notice: t('flash.no_record', model: t('activerecord.models.wallet'))
    end
  end

  def destroy
    begin
      wallet = current_user.wallets.find(params[:wallet_id])
      if !params[:confirmed].blank? and params[:confirmed].to_i == 1
        wallet.destroy_without_expenses
      elsif params[:confirmed].to_i == 2
        wallet.destroy
      end
      redirect_to wallets_path, notice: t('flash.delete_one', model: t('activerecord.models.wallet'))
    rescue ActiveRecord::RecordNotFound
      redirect_to wallets_path, notice: t('flash.no_record', model: t('activerecord.models.wallet'))
    end
  end

  def confirm_destroy
    begin
      @wallet = current_user.wallets.find(params[:wallet_id])
      redirect_to wallet_destroy_path(@wallet, confirmed: 1) if @wallet.expenses_number == 0
    rescue ActiveRecord::RecordNotFound
      redirect_to wallets_path, notice: t('flash.no_record', model: t('activerecord.models.wallet'))
    end
  end
end