class AccountUsersController < Accounts::BaseController
  before_action :authenticate_user!
  before_action :set_account
  before_action :require_non_personal_account!
  before_action :set_account_user, only: [:edit, :update, :destroy]
  before_action :require_account_admin, except: [:index, :show]
  before_action :safeguard_account_owner_deletion!, only: [:destroy]

  # GET /accounts
  def index
    redirect_to @account
  end

  # GET /account_users/1
  def show
    redirect_to @account
  end

  # GET /account_users/1/edit
  def edit
  end

  # PATCH/PUT /account_users/1
  def update
    if @account_user.update(account_user_params)
      redirect_to @account, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /account_users/1
  def destroy
    @account_user.destroy
    redirect_to @account, status: :see_other, notice: t(".destroyed")
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to accounts_path
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_account_user
    @account_user = @account.account_users.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_user_params
    params.require(:account_user).permit(*AccountUser::ROLES)
  end

  def require_non_personal_account!
    redirect_to accounts_path if @account.personal?
  end

  def safeguard_account_owner_deletion!
    redirect_to @account, alert: t(".not_allowed") if @account_user.account_owner?
  end
end
