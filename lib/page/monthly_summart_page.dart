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
  final double lastMonthExpense; // เพิ่มพารามิเตอร์ใหม่

  const MonthlySummaryPage({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
    required this.lastMonthExpense, // รับพารามิเตอร์ใหม่
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyProvider>(context).currencySymbol;
    final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;

    // คำนวณการเปรียบเทียบรายจ่ายเดือนนี้กับเดือนที่แล้ว
    final difference = expense - lastMonthExpense;
    final comparisonText = difference > 0
        ? AppTranslations.getText('This month more than last month', currentLanguage)
        : AppTranslations.getText('This month less than last month', currentLanguage);

    final formattedDifference =
        NumberFormat('#,##0.00').format(difference.abs());

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
              amount: difference,
              color: difference > 0 ? Colors.red : Colors.green,
              currencySymbol: currencySymbol,
              extraText: '$comparisonText: $formattedDifference $currencySymbol',
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
