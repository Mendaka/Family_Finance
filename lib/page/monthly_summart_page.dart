import 'package:family_finance/language/app_translations.dart';
import 'package:family_finance/language/locale_provider.dart';
import 'package:family_finance/page/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthlySummaryPage extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final double lastMonthExpense;
  final double todayIncome; // รายรับวันนี้
  final double todayExpense; // รายจ่ายวันนี้
  final double yesterdayIncome; // รายรับเมื่อวาน
  final double yesterdayExpense; // รายจ่ายเมื่อวาน

  const MonthlySummaryPage({
    super.key,
   required this.income,
  required this.expense,
  required this.balance,
  required this.lastMonthExpense,
  required this.todayIncome,
  required this.todayExpense,
  required this.yesterdayIncome,
  required this.yesterdayExpense,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyProvider>(context).currencySymbol;
    final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;

    // คำนวณความแตกต่างของรายรับและรายจ่ายวันนี้กับเมื่อวาน
    final incomeDifference = todayIncome - yesterdayIncome;
    final expenseDifference = todayExpense - yesterdayExpense;

    final incomeComparisonText = incomeDifference > 0
        ? AppTranslations.getText('Today more income than yesterday', currentLanguage)
        : AppTranslations.getText('Today less income than yesterday', currentLanguage);

    final expenseComparisonText = expenseDifference > 0
        ? AppTranslations.getText('Today more expense than yesterday', currentLanguage)
        : AppTranslations.getText('Today less expense than yesterday', currentLanguage);

    final formattedIncomeDifference =
        NumberFormat('#,##0.00').format(incomeDifference.abs());
    final formattedExpenseDifference =
        NumberFormat('#,##0.00').format(expenseDifference.abs());

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTranslations.getText('Summary of this month', currentLanguage),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Raleway",
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              icon: Icons.arrow_circle_down,
              label: AppTranslations.getText('Summary of income', currentLanguage),
              amount: income,
              color: Colors.green,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: 10),
            _buildSummaryCard(
              icon: Icons.arrow_circle_up,
              label: AppTranslations.getText('Summary of expenses', currentLanguage),
              amount: expense,
              color: Colors.red,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: 10),
            _buildSummaryCard(
              icon: Icons.account_balance_wallet,
              label: AppTranslations.getText('Summary of balance', currentLanguage),
              amount: balance,
              color: Colors.orange,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: 10),
            _buildSummaryCard(
              icon: Icons.compare_arrows,
              label: AppTranslations.getText('comparison with last month', currentLanguage),
              amount: expense - lastMonthExpense,
              color: (expense - lastMonthExpense) > 0 ? Colors.red : Colors.green,
              currencySymbol: currencySymbol,
              extraText:
                  '${AppTranslations.getText('comparison with last month', currentLanguage)}: ${NumberFormat('#,##0.00').format((expense - lastMonthExpense).abs())} $currencySymbol',
            ),
            const SizedBox(height: 10),
            // การ์ดเปรียบเทียบรายรับวันนี้กับเมื่อวาน
            _buildSummaryCard(
              icon: Icons.arrow_forward,
              label: AppTranslations.getText('Income comparison today vs yesterday', currentLanguage),
              amount: incomeDifference,
              color: incomeDifference > 0 ? Colors.green : Colors.red,
              currencySymbol: currencySymbol,
              extraText: '$incomeComparisonText: $formattedIncomeDifference $currencySymbol',
            ),
            const SizedBox(height: 10),
            // การ์ดเปรียบเทียบรายจ่ายวันนี้กับเมื่อวาน
            _buildSummaryCard(
              icon: Icons.arrow_back,
              label: AppTranslations.getText('Expense comparison today vs yesterday', currentLanguage),
              amount: expenseDifference,
              color: expenseDifference > 0 ? Colors.red : Colors.green,
              currencySymbol: currencySymbol,
              extraText: '$expenseComparisonText: $formattedExpenseDifference $currencySymbol',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required String currencySymbol,
    String? extraText,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Raleway",
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$currencySymbol${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (extraText != null)
                    Text(
                      extraText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: "Raleway",
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
