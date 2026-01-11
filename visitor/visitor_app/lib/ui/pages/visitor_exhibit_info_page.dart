// Veuillet Gaëtan
// 2025
// Description : Exhibit info page, connected from the qr code scan page

// visitor_exhibit_info_page.dart

import 'package:flutter/material.dart';
import 'package:visitor_app/data/visitor.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/data/favorites_dao.dart';
import 'package:visitor_app/utils/language_manager.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return _dateFormatter.format(date);
}

class VisitorExhibitInfoPage extends StatefulWidget {
  final ExhibitDetails exhibitDetails;
  final VisitorDao visitorDao;
  final FavoritesDao favoritesDao;
  final int sessionId;

  const VisitorExhibitInfoPage({
    super.key,
    required this.exhibitDetails,
    required this.visitorDao,
    required this.favoritesDao,
    required this.sessionId,
  });

  @override
  State<VisitorExhibitInfoPage> createState() => _VisitorExhibitInfoPageState();
}

class _VisitorExhibitInfoPageState extends State<VisitorExhibitInfoPage> {
  bool _isLoadingFavorite = false;
  bool _isFavorite = false;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingFeedback = false;
  double _averageRating = 0.0;
  bool _isLoadingAverage = false;
  List<ExhibitFeedback> _feedbacks = [];
  bool _isLoadingFeedbacks = false;

  @override
  void initState() {
    super.initState();
    _loadAverageRating();
    _loadFeedbacks();
    _checkIfFavorite();

    LanguageManager().addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    _reloadExhibitData();
  }

  @override
  void dispose() {
    LanguageManager().removeListener(_onLanguageChanged);
    _commentController.dispose();
    super.dispose();
  }


    Future<void> _reloadExhibitData() async {
    setState(() {
      _isLoadingAverage = true;
    });

    try {
      // Reload exhibit details with new language
      final updatedDetails = await widget.visitorDao.getExhibitDetails(
        widget.exhibitDetails.exhibit_id,
      );

      if (updatedDetails != null && mounted) {
        // Update the exhibit details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VisitorExhibitInfoPage(
              exhibitDetails: updatedDetails,
              visitorDao: widget.visitorDao,
              favoritesDao: widget.favoritesDao,
              sessionId: widget.sessionId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error reloading exhibit data: $e');
      if (mounted) {
        setState(() {
          _isLoadingAverage = false;
        });
      }
    }
  }

    Future<void> _checkIfFavorite() async {
    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      final isFav = await widget.favoritesDao.isFavorite(
        sessionId: widget.sessionId,
        exhibitId: widget.exhibitDetails.exhibit_id,
      );

      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _isLoadingFavorite = false;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  Future<void> _navigateToRelatedExhibit(int exhibitId) async {
  setState(() {
    _isLoadingAverage = true; //Loading indicator
  });

  try {
    //Get the linked exhibit infos
    final relatedExhibitDetails = await widget.visitorDao.getExhibitDetails(exhibitId);
    
    if (relatedExhibitDetails != null && mounted) {
      setState(() {
        _isLoadingAverage = false;
      });
      
      //Naviguate to the linked exhibit
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisitorExhibitInfoPage(
            exhibitDetails: relatedExhibitDetails,
            visitorDao: widget.visitorDao,
            favoritesDao: widget.favoritesDao,
            sessionId: widget.sessionId,
          ),
        ),
      );
    } else {
      if (mounted) {
        setState(() {
          _isLoadingAverage = false;
        });
        _showErrorDialog('Related exhibit not found');
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoadingAverage = false;
      });
      _showErrorDialog('Error loading exhibit: $e');
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

  Future<void> _loadAverageRating() async {
    setState(() {
      _isLoadingAverage = true;
    });
    
    try {
      final average = await widget.visitorDao.getExhibitAverageRating(
        widget.exhibitDetails.exhibit_id,
      );
      
      if (mounted) {
        setState(() {
          _averageRating = average;
          _isLoadingAverage = false;
        });
      }
    } catch (e) {
      print('Error loading average rating: $e');
      if (mounted) {
        setState(() {
          _isLoadingAverage = false;
        });
      }
    }
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _isLoadingFeedbacks = true;
    });
    
    try {
      final feedbacks = await widget.visitorDao.getExhibitFeedbacks(
        widget.exhibitDetails.exhibit_id,
      );
      
      if (mounted) {
        setState(() {
          _feedbacks = feedbacks;
          _isLoadingFeedbacks = false;
        });
      }
    } catch (e) {
      print('Error loading feedbacks: $e');
      if (mounted) {
        setState(() {
          _isLoadingFeedbacks = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
  if (_isLoadingFavorite) return;

  setState(() {
    _isLoadingFavorite = true;
  });

  try {
    final success = await widget.favoritesDao.toggleFavorite(
      sessionId: widget.sessionId,
      exhibitId: widget.exhibitDetails.exhibit_id,
    );

    if (success && mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoadingFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite 
              ? 'add_to_favorites'.tr 
              : 'remove_from_favorites'.tr
          ),
          backgroundColor: Colors.purple[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      setState(() {
        _isLoadingFavorite = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorite'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    print('Error toggling favorite: $e');
    if (mounted) {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }
}

  void _showLongDescription() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'more_information'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.purple[700],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  child: Text(
                    widget.exhibitDetails.longDesc,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[700]!,
                        Colors.deepPurple[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFeedbackDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'give_feedback'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.purple[700]),
                    const SizedBox(height: 16),
                    
                    // Étoiles de notation
                    Text(
                      'rate'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _rating == 0 ? '' : '$_rating / 5 stars'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Champ de commentaire
                    TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'comment'.tr,
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
                        hintText: 'share'.tr,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purple[700]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'cancel'.tr,
                              style: TextStyle(color: Colors.purple[300]),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple[700]!,
                                Colors.deepPurple[700]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmittingFeedback
                                ? null
                                : () async {
                                    if (_rating == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('select_rating'.tr),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
            
                                    setState(() {
                                      _isSubmittingFeedback = true;
                                    });
            
                                    try {
                                      final success = await widget.visitorDao.submitFeedback(
                                        exhibitId: widget.exhibitDetails.exhibit_id,
                                        sessionId: widget.sessionId,
                                        comment: _commentController.text,
                                        rating: _rating,
                                      );
            
                                      if (mounted) {
                                        Navigator.pop(context);
                                        
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('thx_feedback'.tr),
                                              backgroundColor: Colors.purple[700],
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                          await _loadAverageRating();
                                          await _loadFeedbacks();
                                          setState(() {
                                            _rating = 0;
                                            _commentController.clear();
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('fail_feedback'.tr),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      print('Error submitting feedback: $e');
                                      if (mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isSubmittingFeedback = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isSubmittingFeedback
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Submit'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAllFeedbacks() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'all_feedback'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.purple[700]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: _isLoadingFeedbacks
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        )
                      : _feedbacks.isEmpty
                          ? Center(
                              child: Text(
                                'no_feedback'.tr,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _feedbacks.length,
                              itemBuilder: (context, index) {
                                final feedback = _feedbacks[index];
                                return Card(
                                  color: Colors.grey[800],
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            for (int i = 0; i < 5; i++)
                                              Icon(
                                                i < feedback.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat('dd.MM.yyyy').format(feedback.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (feedback.comment.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            feedback.comment,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[700]!,
                        Colors.deepPurple[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'close'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageManager(), 
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              widget.exhibitDetails.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.purple[700],
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: _isLoadingFavorite
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        color: _isFavorite ? Colors.amber : Colors.white,
                      ),
                onPressed: _toggleFavorite,
              ),
              const LanguageSelector(),
            ],
          ),
          body: 
          SingleChildScrollView(
            
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Note moyenne et feedbacks
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[800]!),
                  ),
                  child: Row(
                    children: [
                      if (_isLoadingAverage)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        )
                      else if (_averageRating > 0) ...[
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_averageRating.toStringAsFixed(1)}/5.0',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_feedbacks.length} ${_feedbacks.length == 1 ? 'review'.tr : 'reviews'.tr}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        if (_feedbacks.isNotEmpty) ...[
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.purple[700]!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: _showAllFeedbacks,
                              child: Text(
                                'view_all'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple[300],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ] else
                        Row(
                          children: [
                            Icon(Icons.star_border, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'no_rate',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // IMAGE GALLERY (replace the existing Container with height: 200)
              widget.exhibitDetails.images.isNotEmpty
                ? Container(
                    height: 300,
                    child: PageView.builder(
                      itemCount: widget.exhibitDetails.images.length,
                      itemBuilder: (context, index) {
                        final image = widget.exhibitDetails.images[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple[800]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  image.imageData,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[900],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, 
                                            size: 60, 
                                            color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text(
                                            'error_loading'.tr,
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // Image counter overlay
                                if (widget.exhibitDetails.images.length > 1)
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.purple[700]!,
                                        ),
                                      ),
                                      child: Text(
                                        '${index + 1}/${widget.exhibitDetails.images.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Alt text overlay (optional, shows on tap)
                                if (image.altText.isNotEmpty)
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 14,
                                            color: Colors.purple[300],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            image.altText,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : // No images -  placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[800]!),
                    image: widget.exhibitDetails.imagePath != null && 
                          widget.exhibitDetails.imagePath!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.exhibitDetails.imagePath!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                          )
                        : null,
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[900]!,
                        Colors.grey[800]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: widget.exhibitDetails.imagePath == null ||
                          widget.exhibitDetails.imagePath!.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'no_image'.tr,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
                const SizedBox(height: 20),

                // ÈRE
                if (widget.exhibitDetails.eraName != null && 
                    widget.exhibitDetails.eraName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple[900]!.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple[700]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 16,
                          color: Colors.purple[300],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.exhibitDetails.eraName!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[200],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // THEMES
                if (widget.exhibitDetails.themes.isNotEmpty) ...[
                  //ListenableBuilder(
                  //  listenable: LanguageManager(),
                   // builder: (context, _) {
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'themes'.tr}:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.exhibitDetails.themes
                                .map((theme) => _buildChip(theme))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    //},
                  //),
                ],


                // DATES
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[800]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.purple[300],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${'from'.tr}: ${formatDate(widget.exhibitDetails.startDate)} ${'to'.tr} ${formatDate(widget.exhibitDetails.finalDate)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

              // RELATED EXHIBITS
              if (widget.exhibitDetails.relatedExhibits.isNotEmpty) ...[
                Text(
                  '${'related_exhibits'.tr}:' ,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.exhibitDetails.relatedExhibits.map((related) {
                  return GestureDetector(
                    onTap: () => _navigateToRelatedExhibit(related.exhibit_id),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[800]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.purple[300],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    related.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'click_details'.tr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.purple[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[900]!.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${related.exhibit_id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple[300],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],

                // SECTION DESCRIPTION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[800]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.purple[300],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'description'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.exhibitDetails.shortDesc,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // BOUTONS ACTION
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple[700]!,
                              Colors.deepPurple[700]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _showLongDescription,
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                          label: Text(
                            'more_information'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[800]!,
                              Colors.teal[700]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _showFeedbackDialog,
                          icon: const Icon(Icons.feedback, color: Colors.white),
                          label: Text(
                            'give_feedback'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // INFO DE SESSION
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 16,
                        color: Colors.purple[300],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Session: ${widget.sessionId} | Exhibit: #${widget.exhibitDetails.exhibit_id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
  );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.purple[900]!.withOpacity(0.5),
      side: BorderSide(color: Colors.purple[700]!),
    );
  }
}