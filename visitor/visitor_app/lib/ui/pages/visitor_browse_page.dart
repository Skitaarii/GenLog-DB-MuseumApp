// Veuillet Gaëtan
// 2025
// Description : Browse page with Itineraries and Favorites tabs

import 'package:flutter/material.dart';
import 'package:visitor_app/data/itinerary_dao.dart';
import 'package:visitor_app/data/favorites_dao.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/data/itinerary.dart';
import 'package:visitor_app/data/exhibit.dart';
import 'package:visitor_app/ui/pages/visitor_itinerary_detail_page.dart';
import 'package:visitor_app/ui/pages/visitor_exhibit_info_page.dart';
import 'package:visitor_app/utils/language_manager.dart';


class VisitorBrowsePage extends StatefulWidget {
  final ItineraryDao itineraryDao;
  final FavoritesDao favoritesDao;
  final VisitorDao visitorDao;
  final int sessionId;

  const VisitorBrowsePage({
    super.key,
    required this.itineraryDao,
    required this.favoritesDao,
    required this.visitorDao,
    required this.sessionId,
  });

  @override
  State<VisitorBrowsePage> createState() => _VisitorBrowsePageState();
}

class _VisitorBrowsePageState extends State<VisitorBrowsePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ItineraryWithExhibits>> _itinerariesFuture;
  late Future<List<ExhibitLite>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _itinerariesFuture = widget.itineraryDao.getItinerariesWithExhibits();
    _favoritesFuture = widget.favoritesDao.getFavorites(sessionId: widget.sessionId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToItineraryDetail(ItineraryWithExhibits itinerary) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitorItineraryDetailPage(
          itinerary: itinerary,
          visitorDao: widget.visitorDao,
          favoritesDao: widget.favoritesDao,
          sessionId: widget.sessionId,
        ),
      ),
    );
    // Refresh favorites when coming back
    setState(() {
      _loadData();
    });
  }

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
      // Refresh favorites when coming back
      setState(() {
        _loadData();
      });
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
          'browse_museum'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(
              icon: Icon(Icons.map),
              text: 'itineraries'.tr,
            ),
            Tab(
              icon: Icon(Icons.favorite),
              text: 'favorites'.tr,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ITINERARIES TAB
          _buildItinerariesTab(),
          // FAVORITES TAB
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildItinerariesTab() {
    return FutureBuilder<List<ItineraryWithExhibits>>(
      future: _itinerariesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'err_load_iti'.tr,
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          );
        }

        final itineraries = snapshot.data!;

        if (itineraries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 80, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'no_iti'.tr,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'check_later'.tr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itineraries.length,
          itemBuilder: (context, index) {
            final itinerary = itineraries[index];
            return _buildItineraryCard(itinerary);
          },
        );
      },
    );
  }

  Widget _buildItineraryCard(ItineraryWithExhibits itinerary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple[900]!.withOpacity(0.3),
            Colors.deepPurple[900]!.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[700]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToItineraryDetail(itinerary),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itinerary.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${itinerary.exhibits.length} exhibit${itinerary.exhibits.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.purple[300],
                      size: 20,
                    ),
                  ],
                ),
                if (itinerary.exhibits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'include'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...itinerary.exhibits.take(3).map((exhibit) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.purple[300],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    exhibit.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        if (itinerary.exhibits.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+ ${itinerary.exhibits.length - 3} ${'more'.tr}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.purple[300],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return FutureBuilder<List<ExhibitLite>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'err_load_fav'.tr,
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          );
        }

        final favorites = snapshot.data!;

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'no_fav'.tr,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'tap_star'.tr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final exhibit = favorites[index];
            return _buildFavoriteCard(exhibit);
          },
        );
      },
    );
  }

  Widget _buildFavoriteCard(ExhibitLite exhibit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[800]!),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
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
  }
}