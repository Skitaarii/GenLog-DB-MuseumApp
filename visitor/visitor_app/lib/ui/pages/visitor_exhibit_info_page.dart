// Veuillet Gaëtan
// 2025
// Description : Exhibit info page, connected from the qr code scan page

// visitor_exhibit_info_page.dart

import 'package:flutter/material.dart';
import 'package:visitor_app/data/visitor.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return _dateFormatter.format(date);
}

class VisitorExhibitInfoPage extends StatefulWidget {
  final ExhibitDetails exhibitDetails;
  final VisitorDao visitorDao;
  final int sessionId;

  const VisitorExhibitInfoPage({
    super.key,
    required this.exhibitDetails,
    required this.visitorDao,
    required this.sessionId,
  });

  @override
  State<VisitorExhibitInfoPage> createState() => _VisitorExhibitInfoPageState();
}

class _VisitorExhibitInfoPageState extends State<VisitorExhibitInfoPage> {
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

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite 
            ? 'Added to favorites' 
            : 'Removed from favorites'
        ),
        backgroundColor: Colors.purple[700],
        duration: const Duration(seconds: 2),
      ),
    );
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
                  'More Information',
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
                    child: const Text(
                      'Close',
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
                      'Give Feedback',
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
                      'How would you rate this exhibit?',
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
                      _rating == 0 ? '' : '$_rating / 5 stars',
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
                        labelText: 'Your comment (optional)',
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
                        hintText: 'Share your thoughts about this exhibit...',
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
                              'Cancel',
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
                                        const SnackBar(
                                          content: Text('Please select a rating'),
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
                                              content: const Text('Thank you for your feedback!'),
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
                                            const SnackBar(
                                              content: Text('Failed to submit feedback. Please try again.'),
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
                                : const Text(
                                    'Submit',
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
                  'All Feedback',
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
                                'No feedback yet',
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
                    child: const Text(
                      'Close',
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
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      '${_feedbacks.length} ${_feedbacks.length == 1 ? 'review' : 'reviews'}',
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
                            'View all',
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
                          'No ratings yet',
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

            // IMAGE (si disponible)
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
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No image available',
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
              Text(
                'Themes:',
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
                      'From: ${formatDate(widget.exhibitDetails.startDate)} to ${formatDate(widget.exhibitDetails.finalDate)}',
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
              'Related Exhibits:',
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
                                'Click to view details',
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
                        'Description',
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
                      label: const Text(
                        'More Information',
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
                      label: const Text(
                        'Give Feedback',
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