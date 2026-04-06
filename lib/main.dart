
import 'package:flutter/material.dart';


void main() {
  runApp(const PalindromeDetectiveApp());
}


class PalindromeDetectiveApp extends StatelessWidget {
  const PalindromeDetectiveApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palindrome Detective',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PalindromeScreen(),
    );
  }
}


class PalindromeScreen extends StatefulWidget {
  const PalindromeScreen({super.key});


  @override
  State<PalindromeScreen> createState() => _PalindromeScreenState();
}


class _PalindromeScreenState extends State<PalindromeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  final List<Map<String, dynamic>> _testCases = [
    {'input': 'A man a plan a canal Panama', 'isPal': true},
    {'input': 'race a car', 'isPal': false},
    {'input': 'Hello World', 'isPal': false, 'longest': 'll'},
  ];


  @override
  void initState() {
    super.initState();
    _runTests();
  }


  String _clean(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }


  bool _isPalindrome(String input) {
    final cleaned = _clean(input);
    final reversed = String.fromCharCodes(cleaned.runes.toList().reversed);
    return cleaned == reversed;
  }


  String _longestPalindromicSubstring(String s) {
    if (s.isEmpty) return '';
    String longest = '';
    for (int i = 0; i < s.length; i++) {
      // Odd
      String pal = _expand(s, i, i);
      if (pal.length > longest.length) longest = pal;
      // Even
      pal = _expand(s, i, i + 1);
      if (pal.length > longest.length) longest = pal;
    }
    return longest;
  }


  String _expand(String s, int l, int r) {
    while (l >= 0 && r < s.length && s[l] == s[r]) {
      l--;
      r++;
    }
    return s.substring(l + 1, r);
  }


  void _checkPalindrome() {
    setState(() {
      final input = _controller.text;
      _result = '"$input" is ${ _isPalindrome(input) ? 'palindrome ✅' : 'NOT a palindrome ❌' }';
    });
  }


  void _findLongest() {
    setState(() {
      final input = _controller.text;
      final longest = _longestPalindromicSubstring(input);
      _result = 'Longest in "$input": "$longest"';
    });
  }


  void _runTests() {
    setState(() {
      final buffer = StringBuffer();
      for (var test in _testCases) {
        final isPal = _isPalindrome(test['input']);
        var longest = _longestPalindromicSubstring(test['input']);
        buffer.writeln('Test: ${test['input']}');
        buffer.writeln('  isPalindrome: ${isPal} (${isPal == test['isPal'] ? '✅' : '❌'})');
        buffer.writeln('  Longest: "$longest"');
        buffer.writeln('');
      }
      _result = buffer.toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🕵️ Palindrome Detective'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter phrase',
                hintText: 'A man a plan a canal Panama',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _checkPalindrome, child: const Text('Is Palindrome?')),
                ElevatedButton(onPressed: _findLongest, child: const Text('Longest Substring')),
              ],
            ),
            ElevatedButton(onPressed: _runTests, child: const Text('Run Tests')),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_result, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
