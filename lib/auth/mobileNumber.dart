import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../Widgets/button.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({Key? key}) : super(key: key);

  @override
  State<MobileNumberPage> createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountry = 'Algeria (+213)';
  String _countryCode = '+213';

  final Map<String, String> _countries = {
    'Algeria (+213)': '+213',
    'France (+33)': '+33',
    'Morocco (+212)': '+212',
    'Tunisia (+216)': '+216',
    'USA (+1)': '+1',
  };

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCountry = newValue;
        _countryCode = _countries[newValue]!;
        _phoneController.clear(); // Clear phone input when country changes
      });
    }
  }

  void _onContinue() {
    final phoneNumber = _phoneController.text;

    if (phoneNumber.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    if (phoneNumber.length != 9) {
      _showError('Phone number must be 9 digits');
      return;
    }

    // Full phone number with country code
    final fullPhoneNumber = '$_countryCode$phoneNumber';

    // TODO: Navigate to next page or send verification code
    print('Full phone number: $fullPhoneNumber');

    // Example: Navigate to OTP verification page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => OTPVerificationPage(phoneNumber: fullPhoneNumber),
    //   ),
    // );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Logos/logo.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.ac_unit,
                          size: 40,
                          color: AppColors.roseColor,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BUZZ',
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Welcome Text
              Text(
                'Welcome',
                style: GoogleFonts.dmSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your phone number to get started',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              // Country Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _countries.keys.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Row(
                          children: [
                            Text(
                              _getCountryFlag(country),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              country,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _onCountryChanged,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Phone Number Input
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      _countryCode,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Privacy and agreements text
              Center(
                child: Text(
                  'Privacy and agreements',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Continue Button
              PrimaryButton(text: 'Continue', onPressed: _onContinue),

              const Spacer(),

              // Number Pad (for design reference - keyboard will handle input)
              _buildNumberPad(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getCountryFlag(String country) {
    if (country.contains('Algeria')) return '🇩🇿';
    if (country.contains('France')) return '🇫🇷';
    if (country.contains('Morocco')) return '🇲🇦';
    if (country.contains('Tunisia')) return '🇹🇳';
    if (country.contains('USA')) return '🇺🇸';
    return '🌍';
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          _buildNumberRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildNumberRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildNumberRow(['7', '8', '9']),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80),
              _buildNumberButton('0'),
              SizedBox(
                width: 80,
                height: 60,
                child: IconButton(
                  onPressed: () {
                    if (_phoneController.text.isNotEmpty) {
                      _phoneController.text = _phoneController.text.substring(
                        0,
                        _phoneController.text.length - 1,
                      );
                    }
                  },
                  icon: const Icon(Icons.backspace_outlined),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildNumberButton(number)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    String letters = '';
    if (number == '2') letters = 'ABC';
    if (number == '3') letters = 'DEF';
    if (number == '4') letters = 'GHI';
    if (number == '5') letters = 'JKL';
    if (number == '6') letters = 'MNO';
    if (number == '7') letters = 'PQRS';
    if (number == '8') letters = 'TUV';
    if (number == '9') letters = 'WXYZ';

    return SizedBox(
      width: 80,
      height: 60,
      child: Material(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            if (_phoneController.text.length < 9) {
              _phoneController.text += number;
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
