import 'package:family_finance/language/app_translations.dart';
import 'package:family_finance/language/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionsBarChart extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final Map<String, double> categories;

  const TransactionsBarChart({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;

    // แปลข้อความโดยใช้ AppTranslations
    final incomeLabel = AppTranslations.getText('income', currentLanguage);
    final expenseLabel = AppTranslations.getText('expense', currentLanguage);
    final balanceLabel = AppTranslations.getText('balance', currentLanguage);
    final titleLabel =
        AppTranslations.getText('main_chart_title', currentLanguage);
    final categoryTitle =
        AppTranslations.getText('category_chart_title', currentLanguage);

    // คำนวณค่าสูงสุดสำหรับสเกลของกราฟ
    final double mainMaxValue =
        [income, expense, balance].reduce((a, b) => a > b ? a : b);
    final double categoryMaxValue = categories.values.isNotEmpty
        ? categories.values.reduce((a, b) => a > b ? a : b)
        : 1; // ตั้งค่าเริ่มต้นเป็น 1 เพื่อป้องกันการหารด้วย 0

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // ส่วนแสดงรายรับ รายจ่าย และคงเหลือ
          Text(titleLabel, // แสดงข้อความหลักตามภาษาที่เลือก
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "RobotoMono")),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(incomeLabel, income, mainMaxValue, Colors.green),
              _buildBar(expenseLabel, expense, mainMaxValue, Colors.red),
              _buildBar(balanceLabel, balance, mainMaxValue, Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          // ส่วนแสดงหมวดหมู่ย่อย
          Text(categoryTitle, // แสดงชื่อหมวดหมู่ตามภาษาที่เลือก
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "RobotoMono")),
          const SizedBox(height: 20),
          categories.isEmpty
              ? const Text('No category data available',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: "RobotoMono",
                  )) // กรณีไม่มีข้อมูล
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: categories.entries.map((entry) {
                      final categoryLabel =
                          AppTranslations.getText(entry.key, currentLanguage) ??
                              entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildBar(
                          categoryLabel,
                          entry.value,
                          categoryMaxValue,
                          _getCategoryColor(categoryLabel),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, double maxValue, Color color) {
    final double barHeight = maxValue > 0 ? (value / maxValue).abs() * 200 : 0;
    final double percentage = maxValue > 0 ? (value / maxValue * 100).abs() : 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        Container(
          width: 40,
          height: barHeight,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                
                fontFamily: "RobotoMono")),
        const SizedBox(height: 20),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': // ภาษาอังกฤษ
      case 'อาหาร': // ภาษาไทย
      case 'ၶဝ်ႈၽၵ်း': // ภาษาไทใหญ่
        return Colors.orange;
      case 'items':
      case 'ของใช้':
      case 'ၶွင်ၸႂ်ႉ':
        return Colors.blue;
      case 'Baby':
      case 'นมเด็กและของใช้':
      case 'ၼူမ်းလုၵ်ႈလႄႈၶွင်ၸႂ်ႉ':
        return Colors.purple;
      case 'Clothes':
      case 'เสื้อผ้า':
      case 'သိူဝ်ႈၽႃႈ':
        return Colors.teal;
      case 'Snacks':
      case 'ของว่าง':
      case 'တၢင်းၵိၼ်လဵၼ်ႈ':
        return Colors.yellow;
      case 'Savings':
      case 'เงินออม':
      case 'ငိုၼ်းႁွမ်ၸူႉ':
        return Colors.brown;
      case 'Internet':
      case 'ค่าเน็ต':
      case 'ၵႃႈၼဵတ်ႇ':
        return Colors.cyan;
      default:
        return Colors.grey; // สีเริ่มต้น
    }
  }
}
