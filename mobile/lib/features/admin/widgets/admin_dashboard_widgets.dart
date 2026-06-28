import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class HoverMenuCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const HoverMenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<HoverMenuCard> createState() => HoverMenuCardState();
}

class HoverMenuCardState extends State<HoverMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.color.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _isHovered ? widget.color : AppColors.textGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SystemSettingsDialog extends StatefulWidget {
  const SystemSettingsDialog();

  @override
  State<SystemSettingsDialog> createState() => SystemSettingsDialogState();
}

class SystemSettingsDialogState extends State<SystemSettingsDialog> {
  bool _maintenanceMode = false;
  bool _allowRegister = true;
  bool _sandboxPayments = true;
  bool _kafkaLogging = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: ((scale - 0.85) / 0.15).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppStrings.systemSettingsTitle,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage global environment parameters',
                          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textGrey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _maintenanceMode,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Render storefront offline for deployment activities', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      value: _allowRegister,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Allow Registrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Allow new customer/seller registrations on auth endpoints', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _allowRegister = val),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      value: _sandboxPayments,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Sandbox Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Route transaction requests through simulated test gateways', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _sandboxPayments = val),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      value: _kafkaLogging,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Kafka Trace Debug', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Enable trace logging for publish/subscribe microservice pipelines', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _kafkaLogging = val),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(AppStrings.saveConfigSuccess), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SystemLogsDialog extends StatelessWidget {
  const SystemLogsDialog();

  @override
  Widget build(BuildContext context) {
    final List<String> mockLogs = [
      '2026-06-07T19:10:20.804Z [gateway-service] INFO - Route mapped: /api/admin/users/** -> http://user-service:8081',
      '2026-06-07T19:10:44.026Z [user-service] INFO - Connection initialized successfully with Postgres on shopease-db',
      '2026-06-07T19:10:52.608Z [authentication-service] INFO - Token validation request processed for user buyer@shopease.local',
      '2026-06-07T19:11:00.124Z [order-service] INFO - Started Saga pipeline: ReserveStockCommand for order ID SE2405150001',
      '2026-06-07T19:11:01.350Z [inventory-service] INFO - Reserved stock: Product p1 x 2 units - Transaction committed',
      '2026-06-07T19:11:02.990Z [payment-service] INFO - Processed transaction \$15.00 via mock credit card gateway - Status: SUCCESS',
      '2026-06-07T19:11:05.118Z [order-service] INFO - Completed Saga pipeline: PaymentReceivedEvent - Order SE2405150001 status -> PAID',
      '2026-06-07T19:12:30.452Z [user-service] INFO - Admin updated account details for email test_admin_mgmt_edited@shopease.local',
      '2026-06-07T19:13:00.810Z [product-service] WARN - Cache eviction triggered for product catalog due to memory bounds',
      '2026-06-07T19:14:02.100Z [gateway-service] INFO - Blocked user request: buyer@shopease.local unauthorized access to /api/admin/users',
      '2026-06-07T19:14:55.332Z [user-service] INFO - Deleted user account UUID c0974e5b-2f72-41af-8508-99d15761680b from database',
      '2026-06-07T19:15:37.012Z [gateway-service] INFO - Route matched: GET /api/admin/users (200 OK) - Time elapsed: 14ms',
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: ((scale - 0.85) / 0.15).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: SizedBox(
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppStrings.gatewayLogs,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Realtime microservice routing trace logs',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF0F172A),
                height: 350,
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: mockLogs.length,
                  itemBuilder: (context, index) {
                    final log = mockLogs[index];
                    Color logColor = const Color(0xFF38BDF8);
                    if (log.contains('WARN')) {
                      logColor = const Color(0xFFFBBF24);
                    } else if (log.contains('SUCCESS')) {
                      logColor = const Color(0xFF34D399);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: log.substring(0, 24),
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            TextSpan(
                              text: log.substring(24),
                              style: TextStyle(color: logColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: const Color(0xFF1E293B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E293B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Close Terminal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DonutChartPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.35;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double total = values.fold(0, (sum, value) => sum + value);
    if (total == 0) return;

    double startAngle = -3.141592653589793 / 2;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 3.141592653589793 * 2;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;

  LineChartPainter(this.dataPoints, this.lineColor, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final stepX = dataPoints.length > 1 ? width / (dataPoints.length - 1) : width;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final fillPath = Path();

    final startX = 0.0;
    final startY = height - (dataPoints[0] * height * 0.8) - 10;
    path.moveTo(startX, startY);
    fillPath.moveTo(0, height);
    fillPath.lineTo(startX, startY);

    for (int i = 1; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = height - (dataPoints[i] * height * 0.8) - 10;

      final prevX = (i - 1) * stepX;
      final prevY = height - (dataPoints[i - 1] * height * 0.8) - 10;
      final controlX1 = prevX + (stepX / 2);
      final controlY1 = prevY;
      final controlX2 = prevX + (stepX / 2);
      final controlY2 = y;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
    }

    fillPath.lineTo(width, height);
    fillPath.close();

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      final h = (height / 4) * i;
      canvas.drawLine(Offset(0, h), Offset(width, h), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = height - (dataPoints[i] * height * 0.8) - 10;
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
