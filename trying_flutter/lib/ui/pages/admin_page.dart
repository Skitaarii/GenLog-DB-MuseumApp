// Veuillet Gaëtan
// 2025
// Description : Admin page to delete/create a sample DB. Also, have some button to navigate threw the different apps (for now visitor and editors)
// Partially done with AI (goofy ahh emoji).
// TODO : WHEN ANALYTICS APP ARE FINISHED, NEED TO LINK IT TO HERE TOO


import 'package:flutter/material.dart';
import 'package:trying_flutter/data/admin_dao.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';
import 'package:trying_flutter/data/room_dao.dart';
import 'package:trying_flutter/data/visitor_dao.dart';
import 'package:trying_flutter/ui/pages/editors_home_page.dart';
import 'package:trying_flutter/ui/pages/qr_code_scan_page.dart';
import 'package:trying_flutter/data/analytics_dao.dart';
import 'package:trying_flutter/ui/pages/analytics_dashboard_page.dart';
import 'package:trying_flutter/data/analytics_test_data_generator.dart';

class AdminPage extends StatefulWidget {
  final AdminDao adminDao;
  final ExhibitDao exhibitDao;
  final RoomDao roomDao;
  final VisitorDao visitorDao;
  final AnalyticsDao analyticsDao;
  final int sessionId;

  const AdminPage({
    super.key,
    required this.adminDao,
    required this.exhibitDao,
    required this.roomDao,
    required this.visitorDao,
    required this.analyticsDao,
    required this.sessionId,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isResetting = false;
  bool _isPopulating = false;
  bool _isChecking = false;
  String _statusMessage = '';
  bool _databaseEmpty = true;
  bool _hasSampleData = false;

  @override
  void initState() {
    super.initState();
    _checkDatabaseStatus();
  }

  Future<void> _checkDatabaseStatus() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Checking database status...';
    });

    try {
      final isEmpty = await widget.adminDao.isDatabaseEmpty();
      final hasData = await widget.adminDao.hasSampleData();
      
      setState(() {
        _databaseEmpty = isEmpty;
        _hasSampleData = hasData;
        _statusMessage = isEmpty 
          ? 'Database is empty (no tables)' 
          : hasData
            ? 'Database contains sample data'
            : 'Database structure exists but is empty';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking database: $e';
        _isChecking = false;
      });
    }
  }

  Future<void> _resetDatabase() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Warning', style: TextStyle(color: Colors.white)),
      content: const Text(
        'This will DELETE ALL DATA from the database.\n'
        'This action cannot be undone!\n\n'
        'Are you sure you want to proceed?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.purpleAccent)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('RESET DATABASE'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  setState(() {
    _isResetting = true;
    _statusMessage = 'Resetting database...';
  });

  try {
    final success = await widget.adminDao.resetDatabase();
    
    if (success) {
      setState(() {
        _statusMessage = '✅ Database reset successfully!';
        _databaseEmpty = true;
        _hasSampleData = false;
      });
    } else {
      setState(() {
        _statusMessage = '❌ Failed to reset database';
      });
    }
  } catch (e) {
    setState(() {
      _statusMessage = '❌ Error: $e';
    });
  } finally {
    setState(() {
      _isResetting = false;
    });
  }
}



  Future<void> _populateDatabase() async {
    setState(() {
      _isPopulating = true;
      _statusMessage = 'Populating database with sample data...';
    });

    try {
      final success = await widget.adminDao.populateWithSampleData();
      
      if (success) {
        setState(() {
          _statusMessage = '✅ Database populated successfully!';
          _databaseEmpty = false;
          _hasSampleData = true;
        });
      } else {
        setState(() {
          _statusMessage = '❌ Failed to populate database';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isPopulating = false;
      });
    }
  }

  

  void _navigateToVisitorPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScanPage(
          visitorDao: widget.visitorDao,
          sessionId: widget.sessionId,
        ),
      ),
    );
  }

  void _navigateToEditorPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorsHomePage(
          exhibitDao: widget.exhibitDao,
          roomDao: widget.roomDao,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Titre
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.purple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Database Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Admin tools for development and testing',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Carte d'état de la database
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _databaseEmpty 
                      ? Colors.orange 
                      : _hasSampleData 
                        ? Colors.green 
                        : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _databaseEmpty 
                            ? Icons.warning 
                            : _hasSampleData 
                              ? Icons.check_circle 
                              : Icons.info,
                          color: _databaseEmpty 
                            ? Colors.orange 
                            : _hasSampleData 
                              ? Colors.green 
                              : Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _databaseEmpty 
                              ? 'Database is EMPTY'
                              : _hasSampleData 
                                ? 'Database contains SAMPLE DATA'
                                : 'Database STRUCTURE exists',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isChecking)
                      const LinearProgressIndicator(
                        color: Colors.purple,
                      )
                    else
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: _statusMessage.contains('✅') 
                            ? Colors.green[400]
                            : _statusMessage.contains('❌')
                              ? Colors.red[400]
                              : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              //RESET BUTTON
              _buildActionButton(
                title: 'RESET DATABASE',
                icon: Icons.delete_forever,
                gradientColors: [Colors.red[800]!, Colors.red[900]!],
                shadowColor: Colors.red,
                isLoading: _isResetting,
                loadingText: 'Resetting...',
                onPressed: _resetDatabase,
                disabled: _isResetting || _isPopulating,
              ),
              const SizedBox(height: 20),

              //POPULATE BUTTOn
              _buildActionButton(
                title: 'POPULATE WITH SAMPLE DATA',
                icon: Icons.data_array,
                gradientColors: [Colors.green[800]!, Colors.teal[700]!],
                shadowColor: Colors.teal,
                isLoading: _isPopulating,
                loadingText: 'Populating...',
                onPressed: _populateDatabase,
                disabled: _isResetting || _isPopulating,
              ),
              const SizedBox(height: 40),

              //DEBUG BUTTON HAHA ITS THE FUNNY BUTTON
              ElevatedButton.icon(
                onPressed: () async {
                  final scans = await widget.adminDao.connection.query(
                    'SELECT session_id, exhibit_id, scanned_at FROM QR_Scan ORDER BY scanned_at DESC LIMIT 5'
                  );
    
                  print('\nRecent scans:');
                  for (final row in scans) {
                    print('Session ${row[0]}: Exhibit ${row[1]} at ${row[2]}');
                  }
    
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Check console for scan data'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: Icon(Icons.bug_report),
                label: Text('🔍 Check Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),

              //INFORMATIONS - Waanted by the AI, not really useful
              /*
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const Text(
                      'Sample Data Includes:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    _buildInfoItem('• 6 Exhibits with detailed descriptions'),
                    _buildInfoItem('• 5 Rooms with logical names'),
                    _buildInfoItem('• Room-Exhibit associations'),
                    _buildInfoItem('• 5 Historical Eras (Renaissance, etc.)'),
                    _buildInfoItem('• 5 Themes (Art, Science, History, etc.)'),
                    _buildInfoItem('• Sample feedback and ratings'),
                    _buildInfoItem('• Sample QR scans'),
                    _buildInfoItem('• Tags and thematic associations'),
                    
                  ],
                ),
              ),
              */
              //const SizedBox(height: 40),

              //NAV BUTTOn
              const Text(
                'Quick Navigation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
                            Row(
                children: [
                  Expanded(
                    child: _buildNavigationButton(
                      title: 'Visitor Mode',
                      icon: Icons.qr_code_scanner,
                      color: Colors.blue[700]!,
                      onPressed: _navigateToVisitorPage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNavigationButton(
                      title: 'Editor Mode',
                      icon: Icons.edit,
                      color: Colors.purple[700]!,
                      onPressed: _navigateToEditorPage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // ⭐ NEW
              // ⭐ NEW ANALYTICS BUTTON
              _buildNavigationButton(
                title: 'Analytics Dashboard',
                icon: Icons.analytics,
                color: Colors.orange[700]!,
                onPressed: _navigateToAnalyticsPage,
              ),
              const SizedBox(height: 20),

              //REFRESH BUTTOn
              OutlinedButton.icon(
                onPressed: _checkDatabaseStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple[300],
                  side: BorderSide(color: Colors.purple[700]!),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
    required bool isLoading,
    required String loadingText,
    required VoidCallback onPressed,
    required bool disabled,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loadingText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAnalyticsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsDashboardPage(
          analyticsDao: widget.analyticsDao,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}