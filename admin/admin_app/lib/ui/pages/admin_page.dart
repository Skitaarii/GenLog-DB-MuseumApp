// Veuillet Gaëtan
// 2025
// Description : Admin page to delete/create a sample DB. Also, have some button to navigate threw the different apps (for now visitor and editors)
// Partially done with AI (goofy ahh emoji).


import 'package:flutter/material.dart';
import 'package:admin_app/data/admin_dao.dart';


class AdminPage extends StatefulWidget {
  final AdminDao adminDao;

  final int sessionId;

  const AdminPage({
    super.key,
    required this.adminDao,

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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
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
      final success = await widget.adminDao.populateWithSampleData(reset:true);
      
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

              //INFORMATIONS - Waanted by the AI, not really useful

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