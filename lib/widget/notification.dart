// ------------------------------------------------------
// NOTIFICATION PAGE - FlipRate (SF Pro Edition)
// Notifikasi Real-time berdasarkan Favorite + Reminder
// ------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color primaryGreen = Color(0xFF043915);
  static const Color lightGreen = Color(0xFFF1F8E9);
  static const Color accentGreen = Color(0xFFDDE8D4);

  List<Map<String, dynamic>> notifications = [];
  List<String> favoriteCurrencies = [];
  Map<String, double> currentRates = {};
  Map<String, double> previousRates = {};
  bool isLoading = true;
  int unreadCount = 0;

  final Map<String, String> currencyFlags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'JPY': '🇯🇵',
    'SGD': '🇸🇬',
    'GBP': '🇬🇧',
    'AUD': '🇦🇺',
    'CAD': '🇨🇦',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
    'MYR': '🇲🇾',
    'THB': '🇹🇭',
    'KRW': '🇰🇷',
    'INR': '🇮🇳',
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadFavorites();
    await _loadPreviousRates();
    await _fetchCurrentRates();
    await _loadNotifications();
    await _generateNotifications();
  }

  // Load favorite currencies dari SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_currencies') ?? [];
      setState(() {
        favoriteCurrencies = favoritesJson;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      // Gunakan default favorites jika gagal
      setState(() {
        favoriteCurrencies = ['USD', 'EUR', 'JPY', 'SGD'];
      });
    }
  }

  // Load previous rates untuk comparison
  Future<void> _loadPreviousRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getString('previous_rates');
      if (ratesJson != null) {
        final decoded = json.decode(ratesJson) as Map<String, dynamic>;
        previousRates = decoded.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
      }
    } catch (e) {
      debugPrint('Error loading previous rates: $e');
    }
  }

  // Fetch current rates dari API
  Future<void> _fetchCurrentRates() async {
    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/IDR'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        Map<String, double> newRates = {};
        for (String currency in favoriteCurrencies) {
          if (rates[currency] != null) {
            // Convert ke rate Currency/IDR
            final rateToIDR = 1.0 / (rates[currency] as num).toDouble();
            newRates[currency] = rateToIDR;
          }
        }

        setState(() {
          currentRates = newRates;
        });

        // Save current rates sebagai previous rates untuk next time
        _savePreviousRates(newRates);
      }
    } catch (e) {
      debugPrint('Error fetching rates: $e');
    }
  }

  // Save rates untuk comparison next time
  Future<void> _savePreviousRates(Map<String, double> rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('previous_rates', json.encode(rates));
    } catch (e) {
      debugPrint('Error saving previous rates: $e');
    }
  }

  // Load notifications dari SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifJson = prefs.getString('notifications');
      if (notifJson != null) {
        final List<dynamic> decoded = json.decode(notifJson);
        setState(() {
          notifications = decoded.map((item) {
            final notif = Map<String, dynamic>.from(item);
            notif['time'] = DateTime.parse(notif['time']);
            return notif;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // Save notifications ke SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final toSave = notifications.map((notif) {
        final copy = Map<String, dynamic>.from(notif);
        copy['time'] = (notif['time'] as DateTime).toIso8601String();
        return copy;
      }).toList();
      await prefs.setString('notifications', json.encode(toSave));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Generate notifications berdasarkan perubahan rate
  Future<void> _generateNotifications() async {
    final now = DateTime.now();
    List<Map<String, dynamic>> newNotifications = [];

    // Cek perubahan signifikan pada favorite currencies
    for (String currency in favoriteCurrencies) {
      if (currentRates.containsKey(currency)) {
        final current = currentRates[currency]!;

        // Jika ada previous rate, bandingkan
        if (previousRates.containsKey(currency)) {
          final previous = previousRates[currency]!;
          final changePercent = ((current - previous) / previous) * 100;

          // Jika perubahan >= 1.5% (naik atau turun), buat notifikasi
          if (changePercent.abs() >= 1.5) {
            final isUp = changePercent > 0;
            newNotifications.add({
              'type': 'rate_alert',
              'title': isUp
                  ? '$currency/IDR Naik Signifikan!'
                  : '$currency/IDR Turun Signifikan!',
              'message':
                  'Rate favorit Anda ${isUp ? 'naik' : 'turun'} ${changePercent.abs().toStringAsFixed(1)}% menjadi Rp${_formatNumber(current)}',
              'time': now,
              'icon': isUp ? Icons.trending_up : Icons.trending_down,
              'color': isUp ? Colors.green : Colors.red,
              'isRead': false,
              'currency': currency,
              'flag': currencyFlags[currency] ?? '🌍',
            });
          }
        } else {
          // First time: buat welcome notification
          newNotifications.add({
            'type': 'rate_alert',
            'title': '$currency/IDR Rate Updated',
            'message': 'Current rate: Rp${_formatNumber(current)}',
            'time': now,
            'icon': Icons.info_outline,
            'color': Colors.blue,
            'isRead': false,
            'currency': currency,
            'flag': currencyFlags[currency] ?? '🌍',
          });
        }
      }
    }

    // Tambahkan reminder jika user belum cek dalam 3 hari
    final lastCheck = await _getLastCheckTime();
    if (lastCheck != null && now.difference(lastCheck).inDays >= 3) {
      newNotifications.add({
        'type': 'reminder',
        'title':
            'Sudah ${now.difference(lastCheck).inDays} Hari Tidak Cek Rate',
        'message':
            'Ada pergerakan pada ${favoriteCurrencies.length} currency favorit Anda',
        'time': now,
        'icon': Icons.access_time,
        'color': Colors.orange,
        'isRead': false,
        'currency': null,
        'flag': '⏰',
      });
    }

    // Tambahkan welcome notification jika belum pernah ada notifikasi
    if (notifications.isEmpty && newNotifications.isEmpty) {
      newNotifications.add({
        'type': 'reminder',
        'title': 'Welcome to FlipRate! 👋',
        'message':
            'You will receive notifications when your favorite currency rates change significantly.',
        'time': now,
        'icon': Icons.info_outline,
        'color': primaryGreen,
        'isRead': false,
        'currency': null,
        'flag': '🎉',
      });
    }

    // Gabungkan dengan notifikasi lama dan sort by time
    setState(() {
      notifications = [...newNotifications, ...notifications];
      notifications.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime),
      );
      isLoading = false;
    });

    _calculateUnreadCount();
    _saveNotifications();
    _saveLastCheckTime();
  }

  Future<DateTime?> _getLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getString('last_check_time');
      if (lastCheck != null) {
        return DateTime.parse(lastCheck);
      }
    } catch (e) {
      debugPrint('Error getting last check time: $e');
    }
    return null;
  }

  Future<void> _saveLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_check_time',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving last check time: $e');
    }
  }

  void _calculateUnreadCount() {
    unreadCount = notifications.where((n) => n['isRead'] == false).length;
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
      _calculateUnreadCount();
    });
    _saveNotifications();
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
      _calculateUnreadCount();
    });
    _saveNotifications();
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
      _calculateUnreadCount();
    });
    _saveNotifications();
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear All Notifications?',
          style: TextStyle(fontFamily: 'SF Pro', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(fontFamily: 'SF Pro'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'SF Pro')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notifications.clear();
                unreadCount = 0;
              });
              _saveNotifications();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontFamily: 'SF Pro'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return NumberFormat('#,###', 'id_ID').format(number.round());
    } else if (number >= 1) {
      return number.toStringAsFixed(0);
    } else {
      return number.toStringAsFixed(2);
    }
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'SF Pro'),
      child: Scaffold(
        backgroundColor: lightGreen,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
              fontSize: 20,
            ),
          ),
          backgroundColor: primaryGreen,
          elevation: 0,
          actions: [
            if (unreadCount > 0)
              IconButton(
                icon: const Icon(Icons.done_all, color: Colors.white),
                tooltip: 'Mark all as read',
                onPressed: _markAllAsRead,
              ),
            if (notifications.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: 'Clear all notifications',
                onPressed: _clearAll,
              ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              )
            : notifications.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _initializeData,
                color: primaryGreen,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _buildNotificationCard(notif, index);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontFamily: 'SF Pro',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, int index) {
    final isRead = notif['isRead'] as bool;
    final type = notif['type'] as String;
    final time = notif['time'] as DateTime;

    return Dismissible(
      key: Key('notif_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification deleted',
              style: TextStyle(fontFamily: 'SF Pro'),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : accentGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _markAsRead(index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon/Flag
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (notif['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: notif['currency'] != null
                          ? Text(
                              notif['flag'] as String,
                              style: const TextStyle(fontSize: 24),
                            )
                          : Icon(
                              notif['icon'] as IconData,
                              color: notif['color'] as Color,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notif['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif['message'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _relativeTime(time),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'SF Pro',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: type == 'rate_alert'
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type == 'rate_alert'
                                    ? 'Rate Alert'
                                    : 'Reminder',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: type == 'rate_alert'
                                      ? Colors.blue[700]
                                      : Colors.orange[700],
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method untuk get unread count (dipakai di widget lain)
  static Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifJson = prefs.getString('notifications');
      if (notifJson != null) {
        final List<dynamic> decoded = json.decode(notifJson);
        return decoded.where((n) => n['isRead'] == false).length;
      }
    } catch (e) {
      debugPrint('Error getting unread count: $e');
    }
    return 0;
  }

  // Widget badge notifikasi (untuk digunakan di halaman lain)
  static Widget buildNotificationBadge({
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 22,
            ),
            onPressed: onTap,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
