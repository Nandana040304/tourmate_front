import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _manualTextController = TextEditingController();
  String _selectedSourceLanguage = 'Malayalam';
  String _selectedTargetLanguage = 'English';
  String _extractedText = '';
  String _translatedText = '';
  String? _imagePath;
  bool _isTranslating = false;
  bool _hasError = false;
  String _errorMessage = '';

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _manualTextController.dispose();
    super.dispose();
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
          _extractedText = '';
          _translatedText = '';
          _hasError = false;
          _errorMessage = '';
        });
        
        // Simulate OCR processing (in real app, this would call OCR API)
        _simulateOCR();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  // Simulate OCR text extraction (mock implementation)
  Future<void> _simulateOCR() async {
    setState(() {
      _isTranslating = true;
      _hasError = false;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock extracted Malayalam text (in real app, this would come from OCR)
    final mockMalayalamTexts = [
      'ഈ ബസ് കൊച്ചിയിൽ നിന്ന് തിരുവനന്തപുരത്തേക്ക് പോകുന്നു',
      'യാത്രക്കാരുടെ ശ്രദ്ധയ്ക്ക് - ടിക്കറ്റ് വാങ്ങുക',
      'അടുത്ത ബസ് സ്റ്റോപ്പ് 500 മീറ്റർ അകലെ',
      'പൊതു സ്ഥലത്ത് പുകയരരുത്',
      'സ്ത്രീകൾക്കായി സംവരണിച്ച സീറ്റുകൾ',
    ];

    setState(() {
      _extractedText = mockMalayalamTexts[
        DateTime.now().millisecond % mockMalayalamTexts.length
      ];
      _isTranslating = false;
    });
  }

  // Translate text (mock implementation)
  Future<void> _translateText() async {
    if (_extractedText.isEmpty || _manualTextController.text.isNotEmpty) {
      final sourceText = _manualTextController.text.isNotEmpty 
          ? _manualTextController.text 
          : _extractedText;
      
      if (sourceText.isEmpty) {
        _showError('Please enter text or upload an image');
        return;
      }

      setState(() {
        _isTranslating = true;
        _hasError = false;
      });

      // Simulate translation delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock translations (in real app, this would call translation API)
      final translations = {
        'ഈ ബസ് കൊച്ചിയിൽ നിന്ന് തിരുവനന്തപുരത്തേക്ക് പോകുന്നു': 'This bus goes from Kochi to Thiruvananthapuram',
        'യാത്രക്കാരുടെ ശ്രദ്ധയ്ക്ക് - ടിക്കറ്റ് വാങ്ങുക': 'Attention passengers - Buy tickets',
        'അടുത്ത ബസ് സ്റ്റോപ്പ് 500 മീറ്റർ അകലെ': 'Next bus stop 500 meters away',
        'പൊതു സ്ഥലത്ത് പുകയരരുത്': 'Do not smoke in public places',
        'സ്ത്രീകൾക്കായി സംവരണിച്ച സീറ്റുകൾ': 'Seats reserved for women',
      };

      setState(() {
        _translatedText = translations[sourceText] ?? 'Translation not available';
        _isTranslating = false;
      });
    }
  }

  // Show error message
  void _showError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isTranslating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.translate, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Translator',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 20),
                  _buildExtractedTextSection(),
                  const SizedBox(height: 16),
                  _buildTranslatedTextSection(),
                  const SizedBox(height: 16),
                  _buildManualTextInputSection(),
                  const SizedBox(height: 20),
                  _buildTranslateButton(),
                  if (_hasError) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(),
                  ],
                  const SizedBox(height: 80), // Bottom navigation padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Language selector with pill-shaped buttons
  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSourceLanguage = 'Malayalam';
                  _selectedTargetLanguage = 'English';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedSourceLanguage == 'Malayalam' 
                      ? const Color(0xFF2196F3) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF2196F3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '🇮🇳',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Malayalam',
                      style: TextStyle(
                        color: _selectedSourceLanguage == 'Malayalam' 
                            ? Colors.white 
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSourceLanguage = 'English';
                  _selectedTargetLanguage = 'Malayalam';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTargetLanguage == 'English' 
                      ? const Color(0xFF2196F3) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF2196F3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '🇺🇸',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'English',
                      style: TextStyle(
                        color: _selectedTargetLanguage == 'English' 
                            ? Colors.white 
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Image upload/preview section
  Widget _buildImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _imagePath = null;
                          _extractedText = '';
                          _translatedText = '';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTap: _showImageSourceDialog,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to upload image',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Camera or Gallery',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Extracted text section
  Widget _buildExtractedTextSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Extracted Text (${_selectedSourceLanguage})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _extractedText.isNotEmpty 
                  ? _extractedText 
                  : 'No text extracted yet. Upload an image first.',
              style: TextStyle(
                color: _extractedText.isNotEmpty 
                    ? Colors.black87 
                    : Colors.grey[500],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Translated text section
  Widget _buildTranslatedTextSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Translated Text (${_selectedTargetLanguage})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _translatedText.isNotEmpty 
                  ? _translatedText 
                  : 'Translation will appear here.',
              style: TextStyle(
                color: _translatedText.isNotEmpty 
                    ? Colors.black87 
                    : Colors.grey[500],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Manual text input section
  Widget _buildManualTextInputSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Or type text manually',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _manualTextController,
            decoration: InputDecoration(
              hintText: 'Enter text to translate...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2196F3)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _extractedText = '';
                _translatedText = '';
                _hasError = false;
              });
            },
          ),
        ],
      ),
    );
  }

  // Translate button
  Widget _buildTranslateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isTranslating ? null : _translateText,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: _isTranslating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Translating...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.translate),
                  SizedBox(width: 8),
                  Text(
                    'Translate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Error message display
  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false),
          _buildNavItem(Icons.place, 'Places', false),
          _buildSOSButton(),
          _buildNavItem(Icons.book, 'Diary', false),
          _buildNavItem(Icons.more_horiz, 'More', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pop(context);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? const Color(0xFF2196F3) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF2196F3) : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Emergency SOS'),
            content: const Text('Are you sure you want to send an emergency alert?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Send SOS alert
                },
                child: const Text('Send Alert', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.sos,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
