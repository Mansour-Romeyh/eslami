import 'package:eslami/screens/Pdf%20annotation%20models.dart';
import 'package:eslami/screens/Theme%20controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key}) : super(key: key);

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with TickerProviderStateMixin {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();
  final ThemeController _themeController = Get.put(ThemeController());
  final FlutterTts _flutterTts = FlutterTts(); // إضافة القارئ الصوتي

  bool _isLoading = true;
  bool _hasError = false;
  bool _showDropdown = false;
  bool _isSpeaking = false;
  bool _ttsInitialized = false;
  bool _isPaused = false;

  String _activeMode = 'none';
  String _selectedText = ''; // لحفظ النص المحدد

  List<PdfHighlight> _highlights = [];
  List<PdfNote> _notes = [];
  List<PdfDrawing> _drawings = [];
  List<PdfBookmark> _bookmarks = [];

  List<Offset> _currentDrawingPoints = [];
  Color _selectedColor = const Color(0xFFFFEB3B);
  double _strokeWidth = 3.0;

  late AnimationController _dropdownAnimController;

  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
    _initializeTts(); // تهيئة القارئ الصوتي

    _dropdownAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pdfController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pdfController.pageNumber;
        });
      }
    });
  }

  // تهيئة القارئ الصوتي مع دعم أفضل للعربية
  Future<void> _initializeTts() async {
    try {
      // الحصول على اللغات المتاحة
      List<dynamic>? languages = await _flutterTts.getLanguages;

      // محاولة إيجاد أفضل لغة عربية متاحة
      String arabicLang = "ar";
      if (languages != null) {
        final arabicVariants = ['ar-SA', 'ar-EG', 'ar-AE', 'ar-JO', 'ar'];
        for (var variant in arabicVariants) {
          if (languages.contains(variant)) {
            arabicLang = variant;
            break;
          }
        }
      }

      await _flutterTts.setLanguage(arabicLang);
      await _flutterTts.setSpeechRate(0.45); // سرعة مناسبة للعربية
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // للأندرويد: محاولة استخدام Google TTS
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          List<dynamic>? engines = await _flutterTts.getEngines;
          if (engines != null && engines.contains('com.google.android.tts')) {
            await _flutterTts.setEngine('com.google.android.tts');
          }
        } catch (e) {
          debugPrint('Could not set TTS engine: $e');
        }
      }

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isPaused = false;
          });
        }
      });

      _flutterTts.setErrorHandler((msg) {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isPaused = false;
          });
        }
        Get.snackbar(
          'خطأ في القراءة',
          'تأكد من تثبيت Google TTS وتحميل اللغة العربية',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
          duration: const Duration(seconds: 4),
        );
      });

      _ttsInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      _ttsInitialized = false;
    }
  }

  // قراءة النص المحدد
  Future<void> _speakSelectedText() async {
    // التحقق من تهيئة TTS
    if (!_ttsInitialized) {
      await _initializeTts();
      if (!_ttsInitialized) {
        Get.snackbar(
          'تنبيه',
          'جاري تهيئة القارئ الصوتي...',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.hourglass_top, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
        );
        return;
      }
    }

    if (_selectedText.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'الرجاء تحديد نص للقراءة أولاً',
        backgroundColor: const Color(0xFFAC844D),
        colorText: Colors.white,
        icon: const Icon(Icons.touch_app, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
      });
    } else {
      var result = await _flutterTts.speak(_selectedText);
      if (result == 1) {
        setState(() {
          _isSpeaking = true;
          _isPaused = false;
        });
      }
    }
  }

  // إيقاف القراءة
  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _isPaused = false;
    });
  }

  // إيقاف مؤقت/استئناف
  Future<void> _pauseOrResumeSpeaking() async {
    if (_isSpeaking && !_isPaused) {
      await _flutterTts.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (_isPaused) {
      // للأسف flutter_tts لا يدعم resume، لذا نعيد القراءة
      await _flutterTts.speak(_selectedText);
      setState(() {
        _isPaused = false;
      });
    }
  }

  // دالة لإدخال النص يدوياً
  void _showManualTextInputDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _themeController.getColor('surface'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'إدخال نص للقراءة',
              style: TextStyle(
                color: _themeController.getColor('text'),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.record_voice_over,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اكتب النص الذي تريد سماعه',
              style: TextStyle(
                color: _themeController.getColor('textSecondary'),
                fontSize: 14,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              textDirection: TextDirection.rtl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'اكتب النص هنا...',
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: _themeController.getColor('background'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFFAC844D).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: _themeController.getColor('textSecondary'),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  _selectedText = textController.text;
                });
                Navigator.pop(context);
                _speakSelectedText();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.volume_up, size: 20),
            label: const Text(
              'قراءة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dropdownAnimController.dispose();
    _pdfController.dispose();
    _flutterTts.stop(); // إيقاف القراءة عند الخروج
    super.dispose();
  }

  Future<void> _loadAnnotations() async {
    final prefs = await SharedPreferences.getInstance();

    final highlightsJson = prefs.getString('pdf_highlights');
    if (highlightsJson != null) {
      try {
        final List decoded = jsonDecode(highlightsJson);
        _highlights = decoded.map((e) => PdfHighlight.fromJson(e)).toList();
      } catch (e) {
        print('Error loading highlights: $e');
      }
    }

    final notesJson = prefs.getString('pdf_notes');
    if (notesJson != null) {
      try {
        final List decoded = jsonDecode(notesJson);
        _notes = decoded.map((e) => PdfNote.fromJson(e)).toList();
      } catch (e) {
        print('Error loading notes: $e');
      }
    }

    final drawingsJson = prefs.getString('pdf_drawings');
    if (drawingsJson != null) {
      try {
        final List decoded = jsonDecode(drawingsJson);
        _drawings = decoded.map((e) => PdfDrawing.fromJson(e)).toList();
      } catch (e) {
        print('Error loading drawings: $e');
      }
    }

    final bookmarksJson = prefs.getString('pdf_bookmarks');
    if (bookmarksJson != null) {
      try {
        final List decoded = jsonDecode(bookmarksJson);
        _bookmarks = decoded.map((e) => PdfBookmark.fromJson(e)).toList();
      } catch (e) {
        print('Error loading bookmarks: $e');
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveAnnotations() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'pdf_highlights',
      jsonEncode(_highlights.map((e) => e.toJson()).toList()),
    );

    await prefs.setString(
      'pdf_notes',
      jsonEncode(_notes.map((e) => e.toJson()).toList()),
    );

    await prefs.setString(
      'pdf_drawings',
      jsonEncode(_drawings.map((e) => e.toJson()).toList()),
    );

    await prefs.setString(
      'pdf_bookmarks',
      jsonEncode(_bookmarks.map((e) => e.toJson()).toList()),
    );
  }

  void _addBookmark() {
    showDialog(
      context: context,
      builder: (context) => _BookmarkDialog(
        onSave: (title) {
          final bookmark = PdfBookmark(
            pageNumber: _currentPage,
            title: title,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            createdAt: DateTime.now(),
          );

          setState(() {
            _bookmarks.add(bookmark);
          });

          _saveAnnotations();

          Get.snackbar(
            'تم الحفظ',
            'تم إضافة علامة مرجعية للصفحة $_currentPage',
            backgroundColor: const Color(0xFFAC844D),
            colorText: Colors.white,
            icon: const Icon(Icons.bookmark, color: Colors.white),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 2),
          );
        },
      ),
    );
  }

  void _addNoteAtPosition(Offset position) {
    showDialog(
      context: context,
      builder: (context) => _NoteDialog(
        onSave: (text) {
          final note = PdfNote(
            pageNumber: _currentPage,
            position: position,
            text: text,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            createdAt: DateTime.now(),
            color: _selectedColor,
          );

          setState(() {
            _notes.add(note);
          });

          _saveAnnotations();

          Get.snackbar(
            'تمت الإضافة',
            'تم إضافة الملاحظة بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 2),
          );
        },
      ),
    );
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللون', textDirection: TextDirection.rtl),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تم', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _toggleDropdown() {
    setState(() {
      _showDropdown = !_showDropdown;
    });

    if (_showDropdown) {
      _dropdownAnimController.forward();
    } else {
      _dropdownAnimController.reverse();
      setState(() {
        _activeMode = 'none';
      });
    }
  }

  void _activateNoteMode() {
    setState(() {
      _activeMode = 'note';
      _showDropdown = false;
    });
    _dropdownAnimController.reverse();

    Get.snackbar(
      'وضع الملاحظة نشط',
      'اضغط في أي مكان على الصفحة لإضافة ملاحظة',
      backgroundColor: const Color(0xFFAC844D),
      colorText: Colors.white,
      icon: const Icon(Icons.note_add, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _activateDrawMode() {
    setState(() {
      _activeMode = 'draw';
      _showDropdown = false;
    });
    _dropdownAnimController.reverse();

    Get.snackbar(
      'وضع الرسم نشط',
      'ارسم بإصبعك على الصفحة',
      backgroundColor: const Color(0xFFAC844D),
      colorText: Colors.white,
      icon: const Icon(Icons.draw, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _activateEraserMode() {
    setState(() {
      _activeMode = 'eraser';
      _showDropdown = false;
    });
    _dropdownAnimController.reverse();

    Get.snackbar(
      'وضع الممحاة نشط',
      'اضغط على أي رسم أو ملاحظة لحذفها',
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      icon: const Icon(Icons.auto_fix_high, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _checkAndDeleteAtPosition(Offset position) {
    // التحقق من الملاحظات أولاً
    for (var note
        in _notes.where((n) => n.pageNumber == _currentPage).toList()) {
      final noteRect = Rect.fromCenter(
        center: note.position,
        width: 30,
        height: 30,
      );

      if (noteRect.contains(position)) {
        setState(() {
          _notes.removeWhere((n) => n.id == note.id);
        });
        _saveAnnotations();
        Get.snackbar(
          'تم الحذف',
          'تم حذف الملاحظة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 1),
        );
        return;
      }
    }

    // التحقق من الرسومات
    for (var drawing
        in _drawings.where((d) => d.pageNumber == _currentPage).toList()) {
      for (var point in drawing.points) {
        final distance = (point - position).distance;
        if (distance < 20) {
          setState(() {
            _drawings.removeWhere((d) => d.id == drawing.id);
          });
          _saveAnnotations();
          Get.snackbar(
            'تم الحذف',
            'تم حذف الرسم',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 1),
          );
          return;
        }
      }
    }
  }

  void _deactivateMode() {
    setState(() {
      _activeMode = 'none';
    });

    Get.snackbar(
      'تم الإلغاء',
      'تم إلغاء الوضع النشط',
      backgroundColor: Colors.grey,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final isSmallScreen = size.width < 360;

    return Obx(
      () => Scaffold(
        body: Stack(
          children: [
            // الخلفية
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _themeController.isDarkMode.value
                      ? [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2D2D2D),
                          const Color(0xFF3A3A3A),
                          const Color(0xFF2D2D2D),
                        ]
                      : [
                          const Color(0xFF8BA09E),
                          const Color(0xFFA8B5A8),
                          const Color(0xFFCFC09E),
                          const Color(0xFFF3E5BB),
                        ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),

            // PDF Viewer
            Positioned.fill(
              child: SafeArea(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      isSmallScreen ? 6 : 8,
                      15, // SafeArea handles padding.top completely
                      isSmallScreen ? 6 : 8,
                      10,
                    ),
                    decoration: BoxDecoration(
                      color: _themeController.pdfBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFAC844D).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFAC844D).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          // PDF Viewer
                          SfPdfViewer.asset(
                            'aseets/pdf/book.pdf',
                            key: _pdfViewerKey,
                            controller: _pdfController,
                            enableDoubleTapZooming: true,
                            enableTextSelection: _activeMode == 'none',
                            interactionMode: _activeMode == 'none'
                                ? PdfInteractionMode.selection
                                : PdfInteractionMode.pan,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                            pageLayoutMode: PdfPageLayoutMode.continuous,
                            scrollDirection: PdfScrollDirection.vertical,
                            onTextSelectionChanged:
                                (PdfTextSelectionChangedDetails details) {
                                  setState(() {
                                    _selectedText = details.selectedText ?? '';
                                  });
                                },
                            onDocumentLoaded:
                                (PdfDocumentLoadedDetails details) {
                                  setState(() {
                                    _isLoading = false;
                                    _totalPages = details.document.pages.count;
                                  });
                                },
                            onDocumentLoadFailed:
                                (PdfDocumentLoadFailedDetails details) {
                                  setState(() {
                                    _isLoading = false;
                                    _hasError = true;
                                  });
                                },
                          ),

                          // طبقة التفاعل للأوضاع الخاصة (رسم، ملاحظات، ممحاة)
                          if (_activeMode != 'none')
                            Positioned.fill(
                              child: GestureDetector(
                                onTapDown: (details) {
                                  if (_activeMode == 'note') {
                                    _addNoteAtPosition(details.localPosition);
                                  } else if (_activeMode == 'eraser') {
                                    _checkAndDeleteAtPosition(
                                      details.localPosition,
                                    );
                                  }
                                },
                                onPanStart: (details) {
                                  if (_activeMode == 'draw') {
                                    setState(() {
                                      _currentDrawingPoints = [
                                        details.localPosition,
                                      ];
                                    });
                                  } else if (_activeMode == 'eraser') {
                                    _checkAndDeleteAtPosition(
                                      details.localPosition,
                                    );
                                  }
                                },
                                onPanUpdate: (details) {
                                  if (_activeMode == 'draw') {
                                    setState(() {
                                      _currentDrawingPoints.add(
                                        details.localPosition,
                                      );
                                    });
                                  } else if (_activeMode == 'eraser') {
                                    _checkAndDeleteAtPosition(
                                      details.localPosition,
                                    );
                                  }
                                },
                                onPanEnd: (details) {
                                  if (_activeMode == 'draw' &&
                                      _currentDrawingPoints.isNotEmpty) {
                                    final drawing = PdfDrawing(
                                      pageNumber: _currentPage,
                                      points: List.from(_currentDrawingPoints),
                                      color: _selectedColor,
                                      strokeWidth: _strokeWidth,
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      createdAt: DateTime.now(),
                                    );

                                    setState(() {
                                      _drawings.add(drawing);
                                      _currentDrawingPoints.clear();
                                    });

                                    _saveAnnotations();
                                  }
                                },
                                child: Container(color: Colors.transparent),
                              ),
                            ),

                          // طبقة الرسومات
                          if (!_isLoading && !_hasError)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: AnnotationsPainter(
                                    highlights: _highlights
                                        .where(
                                          (h) => h.pageNumber == _currentPage,
                                        )
                                        .toList(),
                                    drawings: _drawings
                                        .where(
                                          (d) => d.pageNumber == _currentPage,
                                        )
                                        .toList(),
                                    currentDrawing: _currentDrawingPoints,
                                    currentColor: _selectedColor,
                                    strokeWidth: _strokeWidth,
                                  ),
                                ),
                              ),
                            ),

                          // الملاحظات
                          if (!_isLoading && !_hasError)
                            ..._notes
                                .where((n) => n.pageNumber == _currentPage)
                                .map(
                                  (note) => Positioned(
                                    left: note.position.dx - 15,
                                    top: note.position.dy - 15,
                                    child: GestureDetector(
                                      onTap: () => _showNoteContent(note),
                                      onLongPress: () => _deleteNote(note),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: note.color,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.note,
                                          size: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),

                          if (_isLoading) _buildLoadingState(),
                          if (_hasError && !_isLoading) _buildErrorState(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // طبقة لإغلاق القائمة
            if (_showDropdown)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleDropdown,
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),

            if (_showDropdown && !_isLoading && !_hasError)
              Positioned(
                top: topPadding + 65,
                right: isSmallScreen ? 12 : 20,
                left: isSmallScreen ? 12 : 20,
                bottom: 100,
                child: _buildDropdownMenu(isSmallScreen),
              ),

            if (!_isLoading && !_hasError)
              Positioned(
                top: topPadding + 10,
                right: isSmallScreen ? 12 : 20,
                child: _buildFloatingMenuButton(isSmallScreen),
              ),

            if (!_isLoading && !_hasError && !_showDropdown)
              Positioned(
                top: topPadding + 10,
                left: 0,
                right: 0,
                child: Center(child: _buildPageCounter(isSmallScreen)),
              ),

            // شريط الوضع النشط
            if (_activeMode != 'none' && !_isLoading && !_hasError)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(child: _buildActiveModeBar(isSmallScreen)),
              ),

            // شريط التحكم في القراءة الصوتية
            if (_isSpeaking && !_isLoading && !_hasError)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(child: _buildTtsControlBar(isSmallScreen)),
              ),

            // زر القراءة العائم - يظهر دائماً
            if (!_isSpeaking &&
                !_showDropdown &&
                !_isLoading &&
                !_hasError &&
                _activeMode == 'none')
              Positioned(
                bottom: 80,
                left: isSmallScreen ? 16 : 20,
                child: _buildFloatingTtsButton(isSmallScreen),
              ),
          ],
        ),
      ),
    );
  }

  // شريط التحكم في القراءة الصوتية
  Widget _buildTtsControlBar(bool isSmall) {
    return SlideInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 20),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 10 : 12,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _stopSpeaking,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.volume_up, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'جاري القراءة...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // زر القراءة العائم
  Widget _buildFloatingTtsButton(bool isSmall) {
    return BounceInUp(
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر إدخال نص يدوي
          GestureDetector(
            onTap: _showManualTextInputDialog,
            child: Container(
              padding: EdgeInsets.all(isSmall ? 10 : 12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFAC844D), Color(0xFFCFC09E)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFAC844D).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit_note,
                color: Colors.white,
                size: isSmall ? 20 : 24,
              ),
            ),
          ),
          // زر القراءة الصوتية
          GestureDetector(
            onTap: () {
              if (_selectedText.isNotEmpty) {
                _speakSelectedText();
              } else {
                Get.snackbar(
                  'تلميحة',
                  'حدد نص من الصفحة أو اضغط على الزر أعلاه لإدخال نص يدوياً',
                  backgroundColor: const Color(0xFFAC844D),
                  colorText: Colors.white,
                  icon: const Icon(Icons.touch_app, color: Colors.white),
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 16,
                  duration: const Duration(seconds: 4),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(isSmall ? 14 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _selectedText.isNotEmpty
                      ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
                      : [Colors.grey.shade500, Colors.grey.shade400],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _selectedText.isNotEmpty
                        ? const Color(0xFF4CAF50).withOpacity(0.4)
                        : Colors.grey.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.volume_up,
                color: Colors.white,
                size: isSmall ? 24 : 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMenuButton(bool isSmall) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 10 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _themeController.isDarkMode.value
                  ? [const Color(0xFF3A3A3A), const Color(0xFF2D2D2D)]
                  : [const Color(0xFFAC844D), const Color(0xFFCFC09E)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFAC844D).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Icon(
                _showDropdown ? Icons.close : Icons.menu,
                color: Colors.white,
                size: isSmall ? 22 : 26,
              ),
              if (_bookmarks.isNotEmpty && !_showDropdown)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _bookmarks.length > 9 ? '9+' : '${_bookmarks.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu(bool isSmall) {
    return SlideInDown(
      duration: const Duration(milliseconds: 300),
      child: FadeIn(
        duration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _themeController.isDarkMode.value
                    ? [
                        const Color(0xFF3A3A3A).withOpacity(0.98),
                        const Color(0xFF2D2D2D).withOpacity(0.95),
                      ]
                    : [
                        Colors.white.withOpacity(0.98),
                        const Color(0xFFF3E5BB).withOpacity(0.95),
                      ],
              ),
              borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
              border: Border.all(
                color: const Color(0xFFAC844D).withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmall ? 12 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: const Color(0xFFAC844D),
                        size: isSmall ? 20 : 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'أدوات القراءة',
                        style: TextStyle(
                          fontSize: isSmall ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: _themeController.getColor('text'),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),

                  Divider(
                    height: isSmall ? 20 : 24,
                    color: _themeController
                        .getColor('textSecondary')
                        .withOpacity(0.2),
                  ),

                  // قسم القارئ الصوتي - جديد
                  _buildMenuSection(
                    title: 'القارئ الصوتي',
                    isSmall: isSmall,
                    items: [
                      _buildMenuItem(
                        icon: _isSpeaking
                            ? Icons.stop
                            : Icons.record_voice_over,
                        label: _isSpeaking
                            ? 'إيقاف القراءة'
                            : 'قراءة النص المحدد',
                        onTap: () {
                          _speakSelectedText();
                          _toggleDropdown();
                        },
                        isActive: _isSpeaking,
                        isSmall: isSmall,
                      ),
                    ],
                  ),

                  Divider(
                    height: isSmall ? 16 : 20,
                    color: _themeController
                        .getColor('textSecondary')
                        .withOpacity(0.2),
                  ),

                  _buildMenuSection(
                    title: 'الإعدادات',
                    isSmall: isSmall,
                    items: [
                      _buildMenuItem(
                        icon: _themeController.isDarkMode.value
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        label: _themeController.isDarkMode.value
                            ? 'الوضع النهاري'
                            : 'الوضع الليلي',
                        onTap: () => _themeController.toggleTheme(),
                        isActive: false,
                        isSmall: isSmall,
                      ),
                    ],
                  ),

                  Divider(
                    height: isSmall ? 16 : 20,
                    color: _themeController
                        .getColor('textSecondary')
                        .withOpacity(0.2),
                  ),

                  _buildMenuSection(
                    title: 'العلامات المرجعية',
                    isSmall: isSmall,
                    items: [
                      _buildMenuItem(
                        icon: Icons.bookmark_add,
                        label: 'إضافة علامة مرجعية',
                        onTap: () {
                          _addBookmark();
                          _toggleDropdown();
                        },
                        isActive: false,
                        isSmall: isSmall,
                      ),
                      _buildMenuItem(
                        icon: Icons.format_list_bulleted,
                        label: 'عرض العلامات المرجعية',
                        badge: _bookmarks.length,
                        onTap: () {
                          _showBookmarksList();
                          _toggleDropdown();
                        },
                        isActive: false,
                        isSmall: isSmall,
                      ),
                    ],
                  ),

                  Divider(
                    height: isSmall ? 16 : 20,
                    color: _themeController
                        .getColor('textSecondary')
                        .withOpacity(0.2),
                  ),

                  _buildMenuSection(
                    title: 'أدوات التعليق',
                    isSmall: isSmall,
                    items: [
                      _buildMenuItem(
                        icon: Icons.note_add,
                        label: 'إضافة ملاحظة',
                        onTap: _activateNoteMode,
                        isActive: _activeMode == 'note',
                        isSmall: isSmall,
                      ),
                      _buildMenuItem(
                        icon: Icons.draw,
                        label: 'وضع الرسم',
                        onTap: _activateDrawMode,
                        isActive: _activeMode == 'draw',
                        isSmall: isSmall,
                      ),
                      _buildMenuItem(
                        icon: Icons.auto_fix_high,
                        label: 'ممحاة',
                        onTap: _activateEraserMode,
                        isActive: _activeMode == 'eraser',
                        isSmall: isSmall,
                      ),
                      _buildMenuItem(
                        icon: Icons.palette,
                        label: 'اختيار اللون',
                        color: _selectedColor,
                        onTap: _pickColor,
                        isActive: false,
                        isSmall: isSmall,
                      ),
                    ],
                  ),

                  Divider(
                    height: isSmall ? 16 : 20,
                    color: _themeController
                        .getColor('textSecondary')
                        .withOpacity(0.2),
                  ),

                  _buildMenuSection(
                    title: 'الإدارة',
                    isSmall: isSmall,
                    items: [
                      _buildMenuItem(
                        icon: Icons.delete_sweep,
                        label: 'مسح كل التعليقات',
                        onTap: () {
                          _showClearDialog();
                          _toggleDropdown();
                        },
                        isActive: false,
                        isSmall: isSmall,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required bool isSmall,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isSmall ? 6 : 8, right: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFAC844D),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    required bool isSmall,
    int? badge,
    Color? color,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmall ? 6 : 8),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 12,
          vertical: isSmall ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFAC844D).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFFAC844D).withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (badge != null && badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFAC844D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge > 99 ? '99+' : badge.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 13 : 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isDestructive
                    ? Colors.red
                    : (isActive
                          ? const Color(0xFFAC844D)
                          : _themeController.getColor('text')),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    color ??
                    (isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : (isActive
                              ? const Color(0xFFAC844D).withOpacity(0.2)
                              : _themeController
                                    .getColor('textSecondary')
                                    .withOpacity(0.1))),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color != null
                    ? Colors.white
                    : (isDestructive
                          ? Colors.red
                          : (isActive
                                ? const Color(0xFFAC844D)
                                : _themeController.getColor('textSecondary'))),
                size: isSmall ? 18 : 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCounter(bool isSmall) {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _themeController.isDarkMode.value
                ? [
                    const Color(0xFF3A3A3A).withOpacity(0.9),
                    const Color(0xFF2D2D2D).withOpacity(0.85),
                  ]
                : [
                    const Color(0xFFAC844D).withOpacity(0.9),
                    const Color(0xFFCFC09E).withOpacity(0.85),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'صفحة $_currentPage من $_totalPages',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 11 : 13,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildActiveModeBar(bool isSmall) {
    String modeText = '';
    IconData modeIcon = Icons.info;
    Color modeColor = const Color(0xFFAC844D);

    if (_activeMode == 'note') {
      modeText = 'وضع الملاحظة نشط - اضغط في أي مكان';
      modeIcon = Icons.note_add;
      modeColor = const Color(0xFFAC844D);
    } else if (_activeMode == 'draw') {
      modeText = 'وضع الرسم نشط - ارسم بإصبعك';
      modeIcon = Icons.draw;
      modeColor = const Color(0xFFAC844D);
    } else if (_activeMode == 'eraser') {
      modeText = 'وضع الممحاة - اضغط على رسم لحذفه';
      modeIcon = Icons.auto_fix_high;
      modeColor = Colors.red.shade400;
    }

    return SlideInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 20),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 10 : 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [modeColor, modeColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _deactivateMode,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Icon(modeIcon, color: Colors.white, size: isSmall ? 18 : 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                modeText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarksList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: _themeController.getColor('surface'),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _themeController
                        .getColor('textSecondary')
                        .withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: _themeController.getColor('text'),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'العلامات المرجعية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _themeController.getColor('text'),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _bookmarks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: _themeController.getColor('textSecondary'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد علامات مرجعية',
                            style: TextStyle(
                              fontSize: 16,
                              color: _themeController.getColor('textSecondary'),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = _bookmarks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: _themeController.getColor('background'),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFAC844D),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${bookmark.pageNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              bookmark.title,
                              style: TextStyle(
                                color: _themeController.getColor('text'),
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            subtitle: Text(
                              'صفحة ${bookmark.pageNumber}',
                              style: TextStyle(
                                color: _themeController.getColor(
                                  'textSecondary',
                                ),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _bookmarks.removeAt(index);
                                });
                                _saveAnnotations();
                                Navigator.pop(context);
                              },
                            ),
                            onTap: () {
                              _pdfController.jumpToPage(bookmark.pageNumber);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteContent(PdfNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _themeController.getColor('surface'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteNote(note);
                Navigator.pop(context);
              },
            ),
            Text(
              'ملاحظة - صفحة ${note.pageNumber}',
              style: TextStyle(
                color: _themeController.getColor('text'),
                fontSize: 16,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 48),
          ],
        ),
        content: Text(
          note.text,
          style: TextStyle(
            color: _themeController.getColor('text'),
            fontSize: 14,
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _deleteNote(PdfNote note) {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
    });
    _saveAnnotations();
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _themeController.getColor('surface'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'مسح كل التعليقات؟',
          style: TextStyle(color: _themeController.getColor('text')),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'هل تريد مسح جميع الملاحظات والرسومات؟',
          style: TextStyle(color: _themeController.getColor('textSecondary')),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _highlights.clear();
                _notes.clear();
                _drawings.clear();
              });
              _saveAnnotations();
              Navigator.pop(context);
              Get.snackbar(
                'تم المسح',
                'تم مسح جميع التعليقات',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            child: const Text(
              'مسح',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: _themeController.pdfBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFAC844D)),
            const SizedBox(height: 20),
            Text(
              'جاري تحميل الكتاب...',
              style: TextStyle(
                color: _themeController.getColor('textSecondary'),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: _themeController.pdfBackgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 50,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 15),
          Text(
            'تعذر تحميل الملف',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: _themeController.getColor('text'),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() {
              _isLoading = true;
              _hasError = false;
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAC844D),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class AnnotationsPainter extends CustomPainter {
  final List<PdfHighlight> highlights;
  final List<PdfDrawing> drawings;
  final List<Offset> currentDrawing;
  final Color currentColor;
  final double strokeWidth;

  AnnotationsPainter({
    required this.highlights,
    required this.drawings,
    required this.currentDrawing,
    required this.currentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var highlight in highlights) {
      final paint = Paint()
        ..color = highlight.color.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(highlight.bounds, paint);
    }

    for (var drawing in drawings) {
      final paint = Paint()
        ..color = drawing.color
        ..strokeWidth = drawing.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < drawing.points.length - 1; i++) {
        canvas.drawLine(drawing.points[i], drawing.points[i + 1], paint);
      }
    }

    if (currentDrawing.length > 1) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < currentDrawing.length - 1; i++) {
        canvas.drawLine(currentDrawing[i], currentDrawing[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BookmarkDialog extends StatefulWidget {
  final Function(String) onSave;

  const _BookmarkDialog({required this.onSave});

  @override
  State<_BookmarkDialog> createState() => _BookmarkDialogState();
}

class _BookmarkDialogState extends State<_BookmarkDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'إضافة علامة مرجعية',
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _controller,
        textDirection: TextDirection.rtl,
        decoration: const InputDecoration(
          hintText: 'اسم العلامة المرجعية',
          hintTextDirection: TextDirection.rtl,
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSave(_controller.text);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFAC844D),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'حفظ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteDialog extends StatefulWidget {
  final Function(String) onSave;

  const _NoteDialog({required this.onSave});

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'إضافة ملاحظة',
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _controller,
        textDirection: TextDirection.rtl,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'اكتب ملاحظتك هنا...',
          hintTextDirection: TextDirection.rtl,
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSave(_controller.text);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFAC844D),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'حفظ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
