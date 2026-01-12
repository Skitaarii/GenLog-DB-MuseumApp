// language_manager.dart
// Multilingual system for museum application
// Supports FR, EN, IT, DE - Manages language state and UI translations

import 'package:flutter/material.dart';

// Enum representing all supported languages in the app
// Each language has: code (for Flutter locale), shortCode (for UI display),
// displayName (full name), and icon (for language selector)
enum AppLanguage {
  french('fr', 'FR', 'Français', Icons.flag),
  english('en', 'EN', 'English', Icons.flag),
  italian('it', 'IT', 'Italiano', Icons.flag),
  german('de', 'DE', 'Deutsch', Icons.flag);

  const AppLanguage(this.code, this.shortCode, this.displayName, this.icon);
  
  final String code;
  final String shortCode;
  final String displayName;
  final IconData icon;
}

// Singleton class managing app language state using ChangeNotifier pattern
// Notifies listeners when language changes to trigger UI rebuilds
class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  AppLanguage _currentLanguage = AppLanguage.english;
  
  AppLanguage get currentLanguage => _currentLanguage;
  String get languageCode => _currentLanguage.code;
  String get dbColumnName => _currentLanguage.code.toUpperCase(); // Returns FR, EN, IT, DE for DB queries

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
      print('Language changed to: ${language.displayName} (${language.code})');
    }
  }
}

// Reusable dropdown widget for language selection, typically used in AppBars
// Shows either short code (EN) or full name (English) based on showFullNames flag
class LanguageSelector extends StatelessWidget {
  final bool showFullNames;
  final Color? textColor;
  
  const LanguageSelector({
    super.key,
    this.showFullNames = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageManager(),
      builder: (context, child) {
        final manager = LanguageManager();
        
        return PopupMenuButton<AppLanguage>(
          // Custom styled button with language icon and current language display
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: textColor ?? Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  showFullNames 
                    ? manager.currentLanguage.displayName
                    : manager.currentLanguage.shortCode,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: textColor ?? Colors.white,
                ),
              ],
            ),
          ),
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.purple[700]!),
          ),
          // Build dropdown menu items for all supported languages
          itemBuilder: (context) => AppLanguage.values.map((lang) {
            final isSelected = lang == manager.currentLanguage;
            return PopupMenuItem<AppLanguage>(
              value: lang,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Colors.purple[900]!.withOpacity(0.3)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      lang.icon,
                      size: 20,
                      color: isSelected ? Colors.purple[300] : Colors.grey[400],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      lang.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.purple[300],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          onSelected: (AppLanguage language) {
            manager.setLanguage(language);
          },
        );
      },
    );
  }
}

// Centralized translation system for all UI strings in the app
// Uses a nested map structure: Language -> Key -> Translation
class AppStrings {
  // Main translation database - each language maps to its key-value pairs
  // English serves as the fallback language if a translation is missing
  static final Map<AppLanguage, Map<String, String>> _strings = {
    AppLanguage.french: {
      'exhibit_info': 'Informations sur l\'exposition',
      'session': 'Session',
      'exhibit': 'Exposition',
      'error': 'Erreur',

      // INFOS EXHIBIT
      'give_feedback': 'Donner un avis',
      'thx_feedback': 'Merci pour votre retour !',
      'fail_feedback': 'Envoie du retour échoué. S\'il vous plaît réessayez.',
      'all_feedback': 'Tous les retours',
      'no_feedback': 'Pas de retour pour l\'instant.',
      'close': 'Fermer',
      'rate':'Combien noteriez-vous cette exposition ?',
      'select_rating':'S\'il vous plaît, notez',
      'no_rate': 'Pas de notes pour l\'instant',
      'comment':'Votre commentaire (optionnel)',
      'share': 'Partagez vos pensées vis-à-vis de cette exposition... ',
      'review': 'avis',
      'reviews': 'avis',
      'view_all': 'Voir tous',
      'description': 'Description',
      'more_information': 'Plus d\'informations',
      'from':'Du',
      'to':'au',
      'related_exhibits': 'Expositions liées',
      'themes': 'Thèmes',
      'no_favorites': 'Aucun favori',
      'add_to_favorites': 'Ajouter aux favoris',
      'remove_from_favorites': 'Retirer des favoris',
      'click_details':'Cliquez pour voir les détails',
      'cancel':'Annuler',
      'submit':'Envoyer',
      'no_image':'Pas d\'images disponbiles',

      // QR CODE
      'exhibit_notfound': 'Exposition pas trouvée',
      'qrcode_invalid': 'Format QR code invalide: ',
      'enter_exhibit':'Entrez l\ID de l\'exposition',
      'exhibit_id': 'ID de l\'exposition',
      'exemple':'ex., 1',
      'enter_validNbr': 'Entrez un nombre valide',
      'Go': 'Aller',
      'scan_qr': 'Scanner le QR Code',
      'toggle_flash': 'Allumer le flash',
      'loading': 'Chargement...',
      'camera_qr': 'Tournez la camera en direction du QR code',
      'exhibit_load': 'L\'exposition chargera automatiquement',
      'manual_id':'Entrez l\'id manuellement',

      // BROWSE PAGE
      'browse_museum': 'Explorer le musée',
      'favorites': 'Favoris',
      'itineraries': 'Itinéraires',
      'err_load_iti': 'Erreur de chargement des itinéraires',
      'err_load_fav': 'Erreur de chargement des favoris',
      'no_fav' : 'Pas de favoris pour l\'instant',
      'tap_star':'Tappez l\'⭐ sur les expositions pour les ajouter ici',
      'no_iti': 'Pas d\'itinéraires disponibles',
      'check_later' : 'Revenez plus tard pour des tours guidés !',
      'include': 'Inclus:',
      'more': 'plus',

      // ITINERARY DETAIL
      'add_fav': 'Ajouté aux favoris',
      'rem_fav': 'Retiré des favoris',
      'no_exhibit_iti': 'Pas d\'exposition dans cet itinéraire',
    },
    AppLanguage.english: {
      'exhibit_info': 'Exhibit information',
      'session': 'Session',
      'exhibit': 'Exhibit',
      'error': 'Error',

      // EXHIBIT INFO
      'give_feedback': 'Give feedback',
      'thx_feedback': 'Thank you for your feedback!',
      'fail_feedback': 'Failed to send feedback. Please try again.',
      'all_feedback': 'All feedback',
      'no_feedback': 'No feedback yet.',
      'close': 'Close',
      'rate': 'How would you rate this exhibit?',
      'select_rating': 'Please select a rating',
      'no_rate': 'No ratings yet',
      'comment': 'Your comment (optional)',
      'share': 'Share your thoughts about this exhibit...',
      'review': 'review',
      'reviews': 'reviews',
      'view_all': 'View all',
      'description': 'Description',
      'more_information': 'More information',
      'from': 'From',
      'to': 'to',
      'related_exhibits': 'Related exhibits',
      'themes': 'Themes',
      'no_favorites': 'No favorites',
      'add_to_favorites': 'Add to favorites',
      'remove_from_favorites': 'Remove from favorites',
      'click_details': 'Click to view details',
      'cancel': 'Cancel',
      'submit': 'Submit',
      'no_image': 'No images available',

      // QR CODE
      'exhibit_notfound': 'Exhibit not found',
      'qrcode_invalid': 'Invalid QR code format: ',
      'enter_exhibit': 'Enter exhibit ID',
      'exhibit_id': 'Exhibit ID',
      'exemple': 'e.g., 1',
      'enter_validNbr': 'Enter a valid number',
      'Go': 'Go',
      'scan_qr': 'Scan QR Code',
      'toggle_flash': 'Toggle flash',
      'loading': 'Loading...',
      'camera_qr': 'Point the camera at the QR code',
      'exhibit_load': 'The exhibit will load automatically',
      'manual_id': 'Enter ID manually',
      
      // BROWSE PAGE
      'browse_museum': 'Browse the museum',
      'favorites': 'Favorites',
      'itineraries': 'Itineraries',
      'err_load_iti': 'Error loading itineraries',
      'err_load_fav': 'Error loading favorites',
      'no_fav': 'No favorites yet',
      'tap_star': 'Tap the ⭐ on exhibits to add them here',
      'no_iti': 'No itineraries available',
      'check_later': 'Check back later for guided tours!',
      'include': 'Includes:',
      'more': 'more',

      // ITINERARY DETAIL
      'add_fav': 'Added to favorites',
      'rem_fav': 'Removed from favorites',
      'no_exhibit_iti': 'No exhibits in this itinerary',
    },
        AppLanguage.italian: {
      'exhibit_info': 'Informazioni sulla mostra',

      'session': 'Sessione',
      'exhibit': 'Mostra',
      'error': 'Errore',

      // EXHIBIT INFO
      'give_feedback': 'Lascia un commento',
      'thx_feedback': 'Grazie per il tuo feedback!',
      'fail_feedback': 'Invio del feedback non riuscito. Riprova.',
      'all_feedback': 'Tutti i feedback',
      'no_feedback': 'Nessun feedback per ora.',
      'close': 'Chiudi',

      'rate': 'Come valuteresti questa mostra?',
      'select_rating': 'Seleziona una valutazione',
      'no_rate': 'Nessuna valutazione per ora',
      'comment': 'Il tuo commento (opzionale)',
      'share': 'Condividi le tue impressioni su questa mostra...',

      'review': 'recensione',
      'reviews': 'recensioni',
      'view_all': 'Vedi tutto',

      'description': 'Descrizione',
      'more_information': 'Maggiori informazioni',
      'from': 'Dal',
      'to': 'al',
      'related_exhibits': 'Mostre correlate',
      'themes': 'Temi',
      'no_favorites': 'Nessun preferito',
      'add_to_favorites': 'Aggiungi ai preferiti',
      'remove_from_favorites': 'Rimuovi dai preferiti',
      'click_details': 'Clicca per vedere i dettagli',
      'cancel': 'Annulla',
      'submit': 'Invia',
      'no_image': 'Nessuna immagine disponibile',

      // QR CODE
      'exhibit_notfound': 'Mostra non trovata',
      'qrcode_invalid': 'Formato QR code non valido: ',
      'enter_exhibit': 'Inserisci ID mostra',
      'exhibit_id': 'ID mostra',
      'exemple': 'es., 1',
      'enter_validNbr': 'Inserisci un numero valido',
      'Go': 'Vai',
      'scan_qr': 'Scansiona QR Code',
      'toggle_flash': 'Attiva flash',
      'loading': 'Caricamento...',
      'camera_qr': 'Inquadra il QR code con la fotocamera',
      'exhibit_load': 'La mostra verrà caricata automaticamente',
      'manual_id': 'Inserisci ID manualmente',

      // BROWSE PAGE
      'browse_museum': 'Esplora il museo',
      'favorites': 'Preferiti',
      'itineraries': 'Itinerari',
      'err_load_iti': 'Errore nel caricamento degli itinerari',
      'err_load_fav': 'Errore nel caricamento dei preferiti',
      'no_fav': 'Nessun preferito al momento',
      'tap_star': 'Tocca la ⭐ sulle mostre per aggiungerle qui',
      'no_iti': 'Nessun itinerario disponibile',
      'check_later': 'Torna più tardi per i tour guidati!',
      'include': 'Include:',
      'more': 'altro',

      // ITINERARY DETAIL
      'add_fav': 'Aggiunto ai preferiti',
      'rem_fav': 'Rimosso dai preferiti',
      'no_exhibit_iti': 'Nessuna mostra in questo itinerario',
    },

    AppLanguage.german: {
      'exhibit_info': 'Ausstellungsinformationen',

      'session': 'Sitzung',
      'exhibit': 'Ausstellung',
      'error': 'Fehler',

      // EXHIBIT INFO
      'give_feedback': 'Feedback geben',
      'thx_feedback': 'Vielen Dank für Ihr Feedback!',
      'fail_feedback': 'Feedback konnte nicht gesendet werden. Bitte erneut versuchen.',
      'all_feedback': 'Alle Feedbacks',
      'no_feedback': 'Noch kein Feedback.',
      'close': 'Schließen',

      'rate': 'Wie würden Sie diese Ausstellung bewerten?',
      'select_rating': 'Bitte Bewertung auswählen',
      'no_rate': 'Noch keine Bewertungen',
      'comment': 'Ihr Kommentar (optional)',
      'share': 'Teilen Sie Ihre Meinung zu dieser Ausstellung...',

      'review': 'Bewertung',
      'reviews': 'Bewertungen',
      'view_all': 'Alle anzeigen',

      'description': 'Beschreibung',
      'more_information': 'Weitere Informationen',
      'from': 'Von',
      'to': 'bis',
      'related_exhibits': 'Verwandte Ausstellungen',
      'themes': 'Themen',
      'no_favorites': 'Keine Favoriten',
      'add_to_favorites': 'Zu Favoriten hinzufügen',
      'remove_from_favorites': 'Aus Favoriten entfernen',
      'click_details': 'Klicken, um Details anzuzeigen',
      'cancel': 'Abbrechen',
      'submit': 'Senden',
      'no_image': 'Keine Bilder verfügbar',

      // QR CODE
      'exhibit_notfound': 'Ausstellung nicht gefunden',
      'qrcode_invalid': 'Ungültiges QR-Code-Format: ',
      'enter_exhibit': 'Ausstellungs-ID eingeben',
      'exhibit_id': 'Ausstellungs-ID',
      'exemple': 'z.B. 1',
      'enter_validNbr': 'Gültige Zahl eingeben',
      'Go': 'Los',
      'scan_qr': 'QR-Code scannen',
      'toggle_flash': 'Blitz umschalten',
      'loading': 'Wird geladen...',
      'camera_qr': 'Richten Sie die Kamera auf den QR-Code',
      'exhibit_load': 'Die Ausstellung wird automatisch geladen',
      'manual_id': 'ID manuell eingeben',

      // BROWSE PAGE
      'browse_museum': 'Museum erkunden',
      'favorites': 'Favoriten',
      'itineraries': 'Routen',
      'err_load_iti': 'Fehler beim Laden der Routen',
      'err_load_fav': 'Fehler beim Laden der Favoriten',
      'no_fav': 'Noch keine Favoriten',
      'tap_star': 'Tippen Sie auf ⭐ bei Ausstellungen, um sie hier hinzuzufügen',
      'no_iti': 'Keine Routen verfügbar',
      'check_later': 'Schauen Sie später für Führungen vorbei!',
      'include': 'Enthält:',
      'more': 'mehr',

      // ITINERARY DETAIL
      'add_fav': 'Zu Favoriten hinzugefügt',
      'rem_fav': 'Aus Favoriten entfernt',
      'no_exhibit_iti': 'Keine Ausstellung in dieser Route',
    },
  };

  // Retrieves translation for a given key in the current language
  // Falls back to English if translation not found in current language
  static String get(String key) {
    final lang = LanguageManager().currentLanguage;
    return _strings[lang]?[key] ?? _strings[AppLanguage.english]?[key] ?? key;
  }
}

// Convenience extension for cleaner translation syntax in UI code
// Example: 'exhibit'.tr returns translated string for current language
extension StringTranslation on String {
  String get tr => AppStrings.get(this);
}