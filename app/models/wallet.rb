class Wallet < ActiveRecord::Base
  attr_accessible :name, :amount, :expenses_attributes
  before_create :initialize_amounts

  has_many :expenses, inverse_of: :wallet, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :expenses

  validates_presence_of :name, :user
  validates :amount, numericality: { decimal: true }, allow_blank: true

  def expenses_number
    expenses.size
  end

  def destroy_without_expenses
    Expense.change_wallet(self.id)
    destroy
  end

  private
  def initialize_amounts
    @sum = 0
    self.expenses.each { |e| @sum+=e.amount }
    self.amount = @sum if @sum > 0
  end
end
