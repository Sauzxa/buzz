import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../Widgets/button.dart';

class PaymentInfoPage extends StatefulWidget {
  const PaymentInfoPage({Key? key}) : super(key: key);

  @override
  State<PaymentInfoPage> createState() => _PaymentInfoPageState();
}

class _PaymentInfoPageState extends State<PaymentInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eccpController = TextEditingController();

  @override
  void dispose() {
    _eccpController.dispose();
    super.dispose();
  }

  void _saveInfo() {
    if (_formKey.currentState!.validate()) {
      // Logic to save ECCP info (e.g. to shared prefs or state)
      // For now, just show success and pop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ECCP Info saved successfully'),
          backgroundColor: AppColors.greenColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'ECCP Payment Info',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.roseColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your ECCP Account Details',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your 20-digit CCP account number.',
                style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _eccpController,
                keyboardType: TextInputType.number,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'ECCP Number',
                  hintText: '00000000000000000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.roseColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ECCP number';
                  }
                  if (value.length < 20) {
                    return 'ECCP number must be at least 20 digits';
                  }
                  return null;
                },
              ),

              const Spacer(),

              PrimaryButton(text: 'Save Information', onPressed: _saveInfo),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
