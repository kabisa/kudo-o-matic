class TransactionsController < ApplicationController
  protect_from_forgery with: :exception

  before_action :check_team_membership
  before_action :query_variables
  before_action :set_transaction
  before_action :check_slack_connection, only: [:index, :create]
  before_action :set_user, only: [:index, :create, :show, :update, :destroy]
  before_action :danger_methods, :edit_or_delete_max_time, only: [:update, :edit, :destroy]

  before_action :check_restricted
  after_action :update_slack_transaction, only: [:upvote, :downvote]

  def index
    @transaction = Transaction.new
    @transaction_decorate = @transaction.decorate
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @transaction = @transaction.decorate
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @transaction = TransactionAdder.create(params[:transaction], current_user, current_team)

    if @transaction.save
      redirect_to :dashboard, team: current_team.slug
    else
      render :index
    end
  end

  def destroy
    if @transaction.delete
      flash[:success] = 'Succesfully removed transaction!'
    end
    redirect_to root_path
  end

  def update
    if @transaction.update(transaction_params)
      if transaction_params["image_delete_checkbox"] == "1"
        @transaction.image.clear
        @transaction.save
      end
      flash[:success] = 'Successfully updated transaction!'
    end
    redirect_to @transaction
  end

  def upvote
    @transaction.liked_by current_user

    respond_to do |format|
      format.html {redirect_to :back}
      format.js
    end

    if Balance.current(current_team.id).amount >= Goal.next(current_team.id).amount
      GoalReacher.check!(current_team.id)
    end
  end

  def downvote
    @transaction.unliked_by current_user

    respond_to do |format|
      format.html {redirect_to :back}
      format.js
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find_by_id_and_team_id(params[:id], current_team.id)
  end

  def update_slack_transaction
    SlackService.instance.send_updated_transaction(@transaction)
  end

  def check_slack_connection
    if current_team.slack_team_id.present?
      if SLACK_IS_CONFIGURED && current_team.membership_of(current_user).slack_id.blank?
        url = "<a href='#{settings_url(team: current_team.slug)}'>Connect your ₭udo-o-Matic account to Slack</a>"
        flash.now[:warning] = url.html_safe
      end
    end
  end

  def query_variables
    @previous = Goal.previous(current_team.id).decorate
    @next = Goal.next(current_team.id).decorate
    @iterate_goals = current_team.current_goals
    @goals = Goal.all.order(cached_votes_up: :desc)
    @current_goals = Goal.all.where(balance: Balance.current(current_team.id)).order('amount desc')
    @balance = Balance.current(current_team.id).decorate

    @achieved_goal = Goal.where(balance: Balance.current(current_team.id)).where.not(achieved_on: nil).order('achieved_on desc')

    @sent_transactions_user = Transaction.where(sender: current_user).where(team_id: current_team.id).count
    @received_transactions_user = Transaction.where(team_id: current_team.id).where(receiver: current_user).count + received_transactions_company
    @all_transactions_user = @sent_transactions_user + @received_transactions_user

    period_week = Time.now.beginning_of_week..Time.now.end_of_week
    period_month = Time.now.beginning_of_month..Time.now.end_of_month

    transactions_week = transactions_period(period_week, current_team)
    transactions_month = transactions_period(period_month, current_team)

    @weekly_transactions = transactions_week.count
    @monthly_transactions = transactions_month.count
    @all_transactions = Transaction.where(team_id: current_team.id).count

    @weekly_kudos = transactions_week.sum(:amount) + likes_count_of_period(period_week)
    @monthly_kudos = transactions_month.sum(:amount) + likes_count_of_period(period_month)
    @all_kudos = Transaction.where(team_id: current_team.id).sum(:amount) + likes.count

    @markdown = Redcarpet::Markdown.new(MdEmoji::Render, no_intra_emphasis: true)

    case params['filter']
    when 'mine'
      @transactions = Transaction.all_for_user_in_team(current_user, current_team).page(params[:page]).per(20)
    when 'send'
      @transactions = Transaction.send_by_user(current_user, current_team).page(params[:page]).per(20)
    when 'received'
      @transactions = TransactionDecorator.decorate_collection(
          Transaction.received_by_user(current_user, current_team).page(params[:page]).per(20)
      )
    else
      @transactions = TransactionDecorator.decorate_collection(
          Transaction.where(team_id: current_team)
              .order('created_at desc').page(params[:page]).per(20)
      )
    end
  end

  def transactions_period(period, team)
    Transaction.where(created_at: period).where(team_id: team.id)
  end

  def likes
    Transaction.joins("INNER JOIN votes on votes.votable_id = transactions.id and votable_type='Transaction'")
  end

  def likes_count_of_period(period)
    likes.where(created_at: period).count
  end

  def received_transactions_company
    user = current_team.users.find_by_name_and_company_user(
        current_team.name,
        true
    )
    Transaction.where(receiver: user).count
  end

  def set_user
    @user = current_user
  end

  def check_restricted
    if current_user.restricted?
      redirect_to root_url
    end
  end

  def danger_methods
    if current_user.id != @transaction.sender_id
      return true if current_user.admin_of?(current_team)
      flash[:error] = "You're not authorized to perform this action!"
      redirect_to root_url
    end
  end

  def edit_or_delete_max_time
    return true if current_user.admin_of?(current_team)
    if @transaction.created_at < Transaction.editable_time
      flash[:error] = "You can only edit/delete your transaction the first 15 minutes after it is created!"
      redirect_to root_url
    end
  end

  def transaction_params
    params.require(:transaction).permit(:receiver_name, :amount, :password, :activity_name, :image, :image_delete_checkbox)
  end
end
