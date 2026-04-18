import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ImageScannerService {
  final _picker = ImagePicker();
  // Hum recognizer ko final nahi rakhte taakay har baar naya use ho ya sahi se close ho
  final _textRecognizer = TextRecognizer();

  Future<String?> scanBillAndGetAmount() async {
    // 1. Camera se photo len
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    // 2. ML Kit ko photo dein
    final inputImage = InputImage.fromFilePath(image.path);
    
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 3. Regex use kar ke text mein se amount dhoondna
      // Yeh pattern numbers (e.g. 500 ya 120.50) ko dhoondta hai
      RegExp regExp = RegExp(r'\d+(?:\.\d+)?'); 
      Iterable<RegExpMatch> matches = regExp.allMatches(recognizedText.text);
      
      if (matches.isNotEmpty) {
        // Sab se bari value ko 'Total' samajhna
        List<double> amounts = matches.map((m) => double.parse(m.group(0)!)).toList();
        amounts.sort();
        return amounts.last.toString(); 
      }
    } catch (e) {
      print("Error scanning text: $e");
    }
    
    return "0.00";
  }

  // 4. Memory saaf karne ke liye function
  void dispose() {
    _textRecognizer.close();
  }
}