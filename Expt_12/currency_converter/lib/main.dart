import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const CurrencyHomePage(),
    );
  }
}

class CurrencyHomePage extends StatefulWidget {
  const CurrencyHomePage({super.key});

  @override
  State<CurrencyHomePage> createState() => _CurrencyHomePageState();
}

class _CurrencyHomePageState extends State<CurrencyHomePage> {
  Map<String, dynamic>? rates;
  String base = 'USD';
  String fromCurrency = 'USD';
  String toCurrency = 'INR';
  double amount = 1.0;
  double converted = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    try {
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/$base');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        rates = Map<String, dynamic>.from(body['rates']);
        // Cache the entire rates map as JSON string
        await prefs.setString('cachedRates', jsonEncode(rates));
        await prefs.setString('cachedBase', base);
      } else {
        throw Exception(
          'Failed to load exchange rates (${response.statusCode})',
        );
      }
    } catch (e) {
      // Load from cache if offline or on error
      final cached = prefs.getString('cachedRates');
      final cachedBase = prefs.getString('cachedBase');
      if (cached != null && cachedBase != null) {
        rates = Map<String, dynamic>.from(jsonDecode(cached));
        base = cachedBase;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loaded cached rates (offline mode)')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load rates: $e')));
      }
    }

    setState(() {
      isLoading = false;
      // make sure selections exist
      if (rates != null) {
        if (!rates!.containsKey(fromCurrency)) fromCurrency = rates!.keys.first;
        if (!rates!.containsKey(toCurrency)) toCurrency = rates!.keys.first;
      }
    });
  }

  void convert() {
    if (rates == null) return;
    final rateFrom = (rates![fromCurrency] as num).toDouble();
    final rateTo = (rates![toCurrency] as num).toDouble();
    setState(() {
      // formula: amount * (rateTo / rateFrom)
      converted = amount * (rateTo / rateFrom);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (rates == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Currency Converter')),
        body: const Center(child: Text('No exchange rate data available')),
      );
    }

    final currencyList = rates!.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('💱 Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRates,
            tooltip: 'Refresh rates',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: fromCurrency,
                    items: currencyList.map((code) {
                      return DropdownMenuItem(value: code, child: Text(code));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => fromCurrency = value!);
                    },
                    decoration: const InputDecoration(
                      labelText: "From",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: toCurrency,
                    items: currencyList.map((code) {
                      return DropdownMenuItem(value: code, child: Text(code));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => toCurrency = value!);
                    },
                    decoration: const InputDecoration(
                      labelText: "To",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: convert,
              style: ElevatedButton.styleFrom(minimumSize: const Size(150, 45)),
              child: const Text("Convert"),
            ),
            const SizedBox(height: 30),
            Text(
              "${amount == amount.toInt() ? amount.toInt() : amount} $fromCurrency = ${converted.toStringAsFixed(4)} $toCurrency",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Base: $base • Rates last fetched from exchangerate-api.com'),
          ],
        ),
      ),
    );
  }
}
