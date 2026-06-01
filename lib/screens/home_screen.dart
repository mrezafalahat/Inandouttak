import 'package:flutter/material.dart';
import 'balance_screen.dart';
import 'forecast_screen.dart';
import 'import_excel_screen.dart';
import 'items_screen.dart';
import 'manual_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final pages = const [
    ForecastScreen(),
    ItemsScreen(),
    ImportExcelScreen(),
    ManualItemScreen(),
    BalanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tak Cash Flow')),
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.show_chart), label: 'پیش‌بینی'),
            NavigationDestination(icon: Icon(Icons.list_alt), label: 'اسناد'),
            NavigationDestination(icon: Icon(Icons.upload_file), label: 'اکسل'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'دستی'),
            NavigationDestination(icon: Icon(Icons.account_balance), label: 'موجودی'),
          ],
        ),
      ),
    );
  }
}
