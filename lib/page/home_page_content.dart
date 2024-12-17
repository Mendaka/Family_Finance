import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:family_finance/language/app_translations.dart';
import 'package:family_finance/language/locale_provider.dart';
import 'package:family_finance/page/currency_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePageContent extends StatefulWidget {
  final Future<Map<String, dynamic>> Function() getTotalAmounts;
  final FirebaseFirestore firestore;

  const HomePageContent(this.getTotalAmounts, this.firestore, {super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currencySymbol =
        Provider.of<CurrencyProvider>(context).currencySymbol;
    final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: widget.getTotalAmounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No data available');
              }

              final totals = snapshot.data!;
              final double totalIncome =
                  (totals['totalIncome'] ?? 0).toDouble();
              final double totalExpense =
                  (totals['totalExpense'] ?? 0).toDouble();
              final double balance = (totals['balance'] ?? 0).toDouble();

              final formattedIncome =
                  NumberFormat('#,##0.00').format(totalIncome);
              final formattedExpense =
                  NumberFormat('#,##0.00').format(totalExpense);
              final formattedBalance = NumberFormat('#,##0.00').format(balance);

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 26, 24, 54),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          title: Text(
                            AppTranslations.getText('income', currentLanguage),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontFamily: "Raleway",
                            ),
                          ),
                          subtitle: Center(
                            child: Text(
                              '$formattedIncome $currencySymbol',
                              style: const TextStyle(
                                fontSize: 35,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Raleway",
                              ),
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTranslations.getText(
                                    'expense', currentLanguage),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontFamily: "Raleway",
                                ),
                              ),
                              Text(
                                '$formattedExpense $currencySymbol',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Raleway",
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppTranslations.getText(
                                    'balance', currentLanguage),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontFamily: "Raleway",
                                ),
                              ),
                              Text(
                                '$formattedBalance $currencySymbol',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: widget.firestore
                .collection('transactions')
                .where('userId', isEqualTo: user?.uid)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No transactions found'));
              }

              final transactions = snapshot.data!.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

              // จัดกลุ่มธุรกรรมตามวันที่
              final groupedTransactions = groupBy(
                transactions,
                (transaction) => DateFormat('yyyy-MM-dd')
                    .format((transaction['date'] as Timestamp).toDate()),
              );

              final sortedKeys = groupedTransactions.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.builder(
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  final date = sortedKeys[index];
                  final dailyTransactions = groupedTransactions[date]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // แสดงวันที่
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(date)),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // แสดงรายการในวันนั้น
                      ...dailyTransactions.map((transaction) {
                        final title =
                            transaction['title'][currentLanguage]?.toString() ??
                                'No title';
                        final amount = (transaction['amount'] ?? 0).toDouble();
                        final time = DateFormat('HH:mm').format(
                            (transaction['date'] as Timestamp).toDate());
                        final type =
                            transaction['type'][currentLanguage]?.toString() ??
                                '';
                        final isIncome = type ==
                            AppTranslations.getText('income', currentLanguage);
                        final color = isIncome ? Colors.green : Colors.red;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              title,
                              style: TextStyle(
                                color: color,
                                fontFamily: "Raleway",
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '${AppTranslations.getText('time', currentLanguage)}: $time',
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppTranslations.getText(
                                    isIncome ? 'income' : 'expense',
                                    currentLanguage,
                                  ),
                                  style: TextStyle(
                                    color: color,
                                    fontFamily: "Raleway",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${amount.toStringAsFixed(2)} $currencySymbol',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}
