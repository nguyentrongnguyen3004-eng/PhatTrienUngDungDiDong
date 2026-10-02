import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class BT7 extends StatelessWidget {
  const BT7({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMS Analyzer',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFF8FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B4B8A),
          brightness: Brightness.light,
        ),
      ),
      home: const SMSAnalyzerScreen(),
    );
  }
}

class SMSAnalyzerScreen extends StatefulWidget {
  const SMSAnalyzerScreen({super.key});

  @override
  State<SMSAnalyzerScreen> createState() => _SMSAnalyzerScreenState();
}

class _SMSAnalyzerScreenState extends State<SMSAnalyzerScreen> {
  final Telephony _telephony = Telephony.instance;
  final TextEditingController _searchController =
      TextEditingController();

  List<SmsMessage> _messages = [];
  List<SmsMessage> _filteredMessages = [];

  bool _isLoading = true;

  int _totalMessages = 0;
  int _advertisementMessages = 0;
  int _otpMessages = 0;
  int _todayMessages = 0;
  int _monthMessages = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    if (statuses[Permission.sms]?.isGranted == true) {
      await _loadMessages();
    } else {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng cấp quyền SMS để đọc tin nhắn.',
          ),
        ),
      );
    }
  }

  Future<void> _loadMessages() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final messages = await _telephony.getInboxSms(
        columns: [
          SmsColumn.ID,
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
          SmsColumn.TYPE,
        ],
        sortOrder: [
          OrderBy(
            SmsColumn.DATE,
            sort: Sort.DESC,
          ),
        ],
      );

      _messages = messages;

      _calculateStatistics();

      _applyFilter(
        _searchController.text,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể đọc SMS: $e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // =========================================================
  // PHÂN LOẠI SMS
  // =========================================================

  bool _isAdvertisement(String body) {
    final text = _normalizeText(body);


    if (text.startsWith('[qc]')) {
      return true;
    }

    final advertisementKeywords = [
      'quang cao',
      'khuyen mai',
      'uu dai',
      'giam gia',
      'mua 1 tang 1',
      'flash sale',
      'sale off',
      'khuyen mai dac biet',
      'uu dai dac biet',
    ];

    for (final keyword in advertisementKeywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  String? _extractOtp(String body) {
    final text = body.trim();

    // =====================================================


    final bracketOtp = RegExp(
      r'^\s*\[OTP\]\s*(\d{6})(?:\s|$)',
      caseSensitive: false,
    ).firstMatch(text);

    if (bracketOtp != null) {
      return bracketOtp.group(1);
    }

    // =====================================================


    final otpPattern = RegExp(
      r'\bOTP\s*(?:code|ma|:|-)?\s*(\d{6})\b',
      caseSensitive: false,
    );

    final otpMatch = otpPattern.firstMatch(text);

    if (otpMatch != null) {
      return otpMatch.group(1);
    }

    // =====================================================


    final otpVietnamesePattern = RegExp(
      r'(?:ma|mã)\s+otp'
      r'(?:\s+cua|\s+của)?'
      r'(?:\s+ban|\s+bạn)?'
      r'(?:\s+la|\s+là)?'
      r'\s*:?\s*(\d{6})\b',
      caseSensitive: false,
    );

    final vietnameseMatch =
        otpVietnamesePattern.firstMatch(text);

    if (vietnameseMatch != null) {
      return vietnameseMatch.group(1);
    }

    // =====================================================


    final verificationPattern = RegExp(
      r'(?:ma|mã)\s+'
      r'(?:xac thuc|xác thực)'
      r'(?:\s+cua|\s+của)?'
      r'(?:\s+ban|\s+bạn)?'
      r'(?:\s+la|\s+là)?'
      r'\s*:?\s*(\d{6})\b',
      caseSensitive: false,
    );

    final verificationMatch =
        verificationPattern.firstMatch(text);

    if (verificationMatch != null) {
      return verificationMatch.group(1);
    }

    // =====================================================

    final englishPattern = RegExp(
      r'(?:your\s+)?otp'
      r'(?:\s+is)?'
      r'\s*:?\s*(\d{6})\b',
      caseSensitive: false,
    );

    final englishMatch =
        englishPattern.firstMatch(text);

    if (englishMatch != null) {
      return englishMatch.group(1);
    }

    return null;
  }

  bool _isOtp(String body) {
    return _extractOtp(body) != null;
  }

  String _normalizeText(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ả', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ạ', 'a')
        .replaceAll('ă', 'a')
        .replaceAll('ắ', 'a')
        .replaceAll('ằ', 'a')
        .replaceAll('ẳ', 'a')
        .replaceAll('ẵ', 'a')
        .replaceAll('ặ', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ấ', 'a')
        .replaceAll('ầ', 'a')
        .replaceAll('ẩ', 'a')
        .replaceAll('ẫ', 'a')
        .replaceAll('ậ', 'a')
        .replaceAll('đ', 'd')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ẻ', 'e')
        .replaceAll('ẽ', 'e')
        .replaceAll('ẹ', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ế', 'e')
        .replaceAll('ề', 'e')
        .replaceAll('ể', 'e')
        .replaceAll('ễ', 'e')
        .replaceAll('ệ', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ỉ', 'i')
        .replaceAll('ĩ', 'i')
        .replaceAll('ị', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ỏ', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ọ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ố', 'o')
        .replaceAll('ồ', 'o')
        .replaceAll('ổ', 'o')
        .replaceAll('ỗ', 'o')
        .replaceAll('ộ', 'o')
        .replaceAll('ơ', 'o')
        .replaceAll('ớ', 'o')
        .replaceAll('ờ', 'o')
        .replaceAll('ở', 'o')
        .replaceAll('ỡ', 'o')
        .replaceAll('ợ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ủ', 'u')
        .replaceAll('ũ', 'u')
        .replaceAll('ụ', 'u')
        .replaceAll('ư', 'u')
        .replaceAll('ứ', 'u')
        .replaceAll('ừ', 'u')
        .replaceAll('ử', 'u')
        .replaceAll('ữ', 'u')
        .replaceAll('ự', 'u')
        .replaceAll('ý', 'y')
        .replaceAll('ỳ', 'y')
        .replaceAll('ỷ', 'y')
        .replaceAll('ỹ', 'y')
        .replaceAll('ỵ', 'y');
  }

  // =========================================================
  // THỐNG KÊ
  // =========================================================

  void _calculateStatistics() {
    int total = 0;
    int advertisement = 0;
    int otp = 0;
    int today = 0;
    int month = 0;

    final now = DateTime.now();

    for (final message in _messages) {
      total++;

      final body = (message.body ?? '').trim();

      if (_isAdvertisement(body)) {
        advertisement++;
      }

      if (_isOtp(body)) {
        otp++;
      }

      final date = _getMessageDate(message);

      if (date != null) {
        if (_isSameDay(date, now)) {
          today++;
        }

        if (date.year == now.year &&
            date.month == now.month) {
          month++;
        }
      }
    }

    _totalMessages = total;
    _advertisementMessages = advertisement;
    _otpMessages = otp;
    _todayMessages = today;
    _monthMessages = month;
  }

  DateTime? _getMessageDate(SmsMessage message) {
    if (message.date == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      message.date!,
    );
  }

  bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // =========================================================
  // LỌC
  // =========================================================

  void _applyFilter(String value) {
    final keyword = value.trim().toLowerCase();

    if (keyword.isEmpty) {
      _filteredMessages =
          List<SmsMessage>.from(_messages);
    } else {
      _filteredMessages = _messages.where((message) {
        final address =
            (message.address ?? '').toLowerCase();

        return address.contains(keyword);
      }).toList();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _clearFilter() {
    _searchController.clear();

    _applyFilter('');
  }

  // =========================================================
  // LOẠI TIN
  // =========================================================

  String _getMessageType(String body) {
    if (_isOtp(body)) {
      return 'OTP';
    }

    if (_isAdvertisement(body)) {
      return 'QC';
    }

    return '';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'OTP':
        return const Color(0xFF7657A8);

      case 'QC':
        return const Color(0xFFE85D75);

      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'OTP':
        return Icons.lock_outline;

      case 'QC':
        return Icons.campaign_outlined;

      default:
        return Icons.message_outlined;
    }
  }

  // =========================================================
  // CHI TIẾT SMS
  // =========================================================

  void _showMessageDetail(SmsMessage message) {
    final body = (message.body ?? '').trim();

    final address =
        message.address ?? 'Không xác định';

    final otp = _extractOtp(body);

    final isAdvertisement =
        _isAdvertisement(body);

    String type = 'Tin nhắn thường';

    if (otp != null) {
      type = 'Tin OTP';
    } else if (isAdvertisement) {
      type = 'Tin quảng cáo';
    }

    final date = _getMessageDate(message);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8FF),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            24,
            18,
            24,
            30,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Chi tiết tin nhắn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _detailRow(
                  Icons.phone,
                  'Số điện thoại',
                  address,
                ),

                _detailRow(
                  Icons.category,
                  'Loại tin nhắn',
                  type,
                ),

                if (date != null)
                  _detailRow(
                    Icons.access_time,
                    'Thời gian',
                    _formatDateTime(date),
                  ),

                const SizedBox(height: 14),

                const Text(
                  'Nội dung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),
                  child: Text(
                    body.isEmpty
                        ? 'Không có nội dung'
                        : body,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),

                if (otp != null) ...[
                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF0E6FF),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'MÃ OTP',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          otp,
                          style:
                              const TextStyle(
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(0xFF76507F),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  // =========================================================
  // GIAO DIỆN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8FF),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFFFF8FF),
        elevation: 0,

        title: const Text(
          'SMS Analyzer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _isLoading
                ? null
                : _loadMessages,
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadMessages,

              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(
                  0,
                  4,
                  0,
                  24,
                ),

                children: [
                  _buildStatisticsCard(),

                  const SizedBox(height: 12),

                  _buildFilterBox(),

                  const SizedBox(height: 16),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 2,
                    ),
                    child: Text(
                      'Tất cả tin nhắn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_filteredMessages.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredMessages.map(
                      _buildMessageCard,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        16,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF8F0F8),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9DDE9),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê SMS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _statText(
            'Tổng số tin nhắn',
            '$_totalMessages',
          ),

          _statText(
            'Tin quảng cáo [QC]',
            '$_advertisementMessages',
          ),

          _statText(
            'Tin OTP',
            '$_otpMessages',
          ),

          _statText(
            'Hôm nay',
            '$_todayMessages tin',
          ),

          _statText(
            'Tháng này',
            '$_monthMessages tin',
          ),
        ],
      ),
    );
  }

  Widget _statText(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 5),
      child: Text(
        '$title: $value',
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFilterBox() {
    return Container(
      height: 58,

      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFF),
        border: Border.all(
          color: Colors.black26,
        ),
        borderRadius:
            BorderRadius.circular(4),
      ),

      child: TextField(
        controller: _searchController,

        onChanged: _applyFilter,

        keyboardType:
            TextInputType.phone,

        decoration: InputDecoration(
          hintText:
              'Lọc theo số điện thoại',

          hintStyle:
              const TextStyle(
            color: Colors.black45,
            fontSize: 16,
          ),

          prefixIcon:
              const Icon(
            Icons.search,
            color: Colors.black45,
          ),

          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed:
                          _clearFilter,
                      icon:
                          const Icon(
                        Icons.close,
                      ),
                    )
                  : null,

          border: InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 17,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    SmsMessage message,
  ) {
    final body =
        (message.body ?? '').trim();

    final address =
        message.address ?? 'Không rõ';

    final type =
        _getMessageType(body);

    final isAdvertisement =
        type == 'QC';

    final isOtp =
        type == 'OTP';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),

      child: Material(
        color:
            const Color(0xFFF8F1F8),

        borderRadius:
            BorderRadius.circular(15),

        child: InkWell(
          borderRadius:
              BorderRadius.circular(15),

          onTap: () {
            _showMessageDetail(
              message,
            );
          },

          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(15),

              border: Border.all(
                color:
                    const Color(0xFFE9E0E9),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.06),
                  blurRadius: 3,
                  offset:
                      const Offset(0, 2),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,

                  decoration:
                      BoxDecoration(
                    color: isAdvertisement
                        ? const Color(
                            0xFFFFE5EA,
                          )
                        : isOtp
                            ? const Color(
                                0xFFEDE3FF,
                              )
                            : const Color(
                                0xFFEDE2FF,
                              ),

                    shape:
                        BoxShape.circle,
                  ),

                  child: Icon(
                    _getTypeIcon(type),
                    color:
                        _getTypeColor(
                      type,
                    ),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),

                          if (type.isNotEmpty)
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    _getTypeColor(
                                  type,
                                ).withOpacity(
                                  0.12,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  8,
                                ),
                              ),

                              child: Text(
                                type,
                                style:
                                    TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      _getTypeColor(
                                    type,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Text(
                        body.isEmpty
                            ? 'Không có nội dung'
                            : body,

                        style:
                            const TextStyle(
                          fontSize: 14,
                          color:
                              Colors.black54,
                        ),

                        maxLines: 2,

                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding:
          const EdgeInsets.all(40),

      alignment: Alignment.center,

      child: Column(
        children: [
          const Icon(
            Icons.sms_outlined,
            size: 55,
            color: Colors.black26,
          ),

          const SizedBox(height: 12),

          const Text(
            'Không có tin nhắn phù hợp',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}