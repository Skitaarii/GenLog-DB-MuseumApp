// Veuillet Gaëtan
// 2025
// Description : QR code scan page, for now it only simulate the page, waiting for REAL usage of camera and qrCode scanning/creation

import 'package:flutter/material.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/ui/pages/visitor_exhibit_info_page.dart';

class QRCodeScanPage extends StatefulWidget {
  final VisitorDao visitorDao;
  final int sessionId;

  const QRCodeScanPage({
    super.key,
    required this.visitorDao,
    required this.sessionId,
  });

  @override
  State<QRCodeScanPage> createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  final TextEditingController _exhibitIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _navigateToExhibitInfo() async {
    if (_formKey.currentState!.validate()) {
      final exhibitId = int.tryParse(_exhibitIdController.text);
      
      if (exhibitId != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          //Register the scan
          await widget.visitorDao.recordQRScan(
            sessionId: widget.sessionId,
            roomId: 1, 
            exhibitId: exhibitId,
          );

          //Get exhibit details
          final exhibitDetails = await widget.visitorDao.getExhibitDetails(exhibitId);

          if (!mounted) return;
          
          setState(() {
            _isLoading = false;
          });

          if (exhibitDetails != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VisitorExhibitInfoPage(
                  exhibitDetails: exhibitDetails,
                  visitorDao: widget.visitorDao,
                  sessionId: widget.sessionId,
                ),
              ),
            );
          } else {
            _showErrorDialog('Exhibit not found');
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('Error: $e');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //QR code icone
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.purple[300]!, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 100,
                      color: Colors.purple[300],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  //Instruction text
                  Text(
                    'Scan the QR code near the exhibit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Or enter the exhibit ID manually',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  //Formualire
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _exhibitIdController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Exhibit ID',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.purple[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.purple[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.purpleAccent),
                            ),
                            prefixIcon: Icon(Icons.numbers, color: Colors.purple[300]),
                            hintText: 'Enter exhibit ID (e.g., 123)',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: Colors.grey[900],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an exhibit ID';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        //Validation button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple[700]!,
                                Colors.deepPurple[700]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _navigateToExhibitInfo,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View Exhibit Details',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  //Session informations
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple[800]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 16,
                          color: Colors.purple[300],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Session ID: ${widget.sessionId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  //DEV BUTTON TO SIMULATE A SCAN -> EXHIBIT ID = 1 
                  TextButton(
                    onPressed: () {
                      _exhibitIdController.text = '1';
                      _navigateToExhibitInfo();
                    },
                    child: const Text(
                      'Simulate scan (Exhibit #1)',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}