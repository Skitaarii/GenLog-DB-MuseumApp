// Veuillet Gaëtan
// 2025
// Description : Itinerary detail page showing all exhibits in the itinerary
// Displays a list of exhibits within a selected itinerary with favorite toggling

import 'package:flutter/material.dart';
import 'package:visitor_app/data/itinerary.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/data/favorites_dao.dart';
import 'package:visitor_app/ui/pages/visitor_exhibit_info_page.dart';
import 'package:visitor_app/utils/language_manager.dart';

class VisitorItineraryDetailPage extends StatefulWidget {
  final ItineraryWithExhibits itinerary; // Itinerary data with its exhibits
  final VisitorDao visitorDao; // For exhibit details retrieval
  final FavoritesDao favoritesDao; // For favorite status management
  final int sessionId; // Current visitor session identifier

  const VisitorItineraryDetailPage({
    super.key,
    required this.itinerary,
    required this.visitorDao,
    required this.favoritesDao,
    required this.sessionId,
  });

  @override
  State<VisitorItineraryDetailPage> createState() =>
      _VisitorItineraryDetailPageState();
}

class _VisitorItineraryDetailPageState
    extends State<VisitorItineraryDetailPage> {
  // Map to track favorite status for each exhibit (exhibit_id -> isFavorite)
  final Map<int, bool> _favoriteStatus = {};
  bool _isLoadingFavorites = true; // Loading state for favorite data

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus(); // Load initial favorite states on page creation
  }

  // Load favorite status for all exhibits in the itinerary
  Future<void> _loadFavoriteStatus() async {
    setState(() {
      _isLoadingFavorites = true;
    });

    // Check favorite status for each exhibit in the itinerary
    for (final exhibit in widget.itinerary.exhibits) {
      final isFav = await widget.favoritesDao.isFavorite(
        sessionId: widget.sessionId,
        exhibitId: exhibit.exhibit_id,
      );
      _favoriteStatus[exhibit.exhibit_id] = isFav;
    }

    if (mounted) {
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  // Toggle favorite status for a specific exhibit
  Future<void> _toggleFavorite(int exhibitId) async {
    final success = await widget.favoritesDao.toggleFavorite(
      sessionId: widget.sessionId,
      exhibitId: exhibitId,
    );

    if (success && mounted) {
      setState(() {
        // Flip the favorite status
        _favoriteStatus[exhibitId] = !(_favoriteStatus[exhibitId] ?? false);
      });

      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoriteStatus[exhibitId] == true
                ? 'add_fav'.tr // Added to favorites
                : 'rem_fav'.tr, // Removed from favorites
          ),
          backgroundColor: Colors.purple[700],
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Navigate to exhibit detail page when an exhibit is tapped
  Future<void> _navigateToExhibitDetail(int exhibitId) async {
    final exhibitDetails = await widget.visitorDao.getExhibitDetails(exhibitId);

    if (exhibitDetails != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisitorExhibitInfoPage(
            exhibitDetails: exhibitDetails,
            visitorDao: widget.visitorDao,
            favoritesDao: widget.favoritesDao,
            sessionId: widget.sessionId,
          ),
        ),
      );
      // Refresh favorite status after returning from exhibit detail
      _loadFavoriteStatus();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('exhibit_notfound'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.itinerary.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header section with itinerary title and exhibit count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[900]!,
                  Colors.deepPurple[900]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.map,
                  size: 60,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.itinerary.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Badge showing number of exhibits in itinerary
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.museum,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.itinerary.exhibits.length} ${'exhibit'.tr}${widget.itinerary.exhibits.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content area - list of exhibits
          Expanded(
            child: widget.itinerary.exhibits.isEmpty
                // Empty state when itinerary has no exhibits
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_exhibit_iti'.tr,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                // List of exhibits with step numbers and favorite buttons
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.itinerary.exhibits.length,
                    itemBuilder: (context, index) {
                      final exhibit = widget.itinerary.exhibits[index];
                      final isFavorite = _favoriteStatus[exhibit.exhibit_id] ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[800]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _navigateToExhibitDetail(exhibit.exhibit_id),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Step number indicator
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple[700]!,
                                          Colors.deepPurple[700]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Exhibit title and ID
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exhibit.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${'exhibit'.tr} #${exhibit.exhibit_id}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Favorite toggle button (only when loading is complete)
                                  if (!_isLoadingFavorites)
                                    IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.star : Icons.star_border,
                                        color: isFavorite ? Colors.amber : Colors.grey[600],
                                        size: 28,
                                      ),
                                      onPressed: () => _toggleFavorite(exhibit.exhibit_id),
                                    ),
                                  
                                  // Navigation arrow
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.purple[300],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}