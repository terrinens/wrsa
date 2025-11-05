import 'package:flutter/material.dart';

// 검색바 위젯
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Search...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Icon(Icons.search, color: Colors.blue[300], size: 28),
        ],
      ),
    );
  }
}
