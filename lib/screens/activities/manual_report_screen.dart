import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n_app_localizations.dart';
import '../../models/green_activity.dart';
import '../../providers/activity_provider.dart';
import '../../utils/app_feedback.dart';

class ManualReportScreen extends StatefulWidget {
  const ManualReportScreen({super.key, this.initialActivity});

  final String? initialActivity;

  @override
  State<ManualReportScreen> createState() => _ManualReportScreenState();
}

class _ManualReportScreenState extends State<ManualReportScreen> {
  String? _selectedActivity;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _activitiesOptions = const [
    'Recycled Plastic Bottles',
    'Used Public Transport',
    'Used A Reusable Bottle',
    'Walked / Biked to Work',
  ];

  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color subtleGreenBorder = Color(0x331B5E20);

  @override
  void initState() {
    super.initState();
    _selectedActivity = widget.initialActivity;
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _image = pickedFile;
      _imageBytes = bytes;
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: darkGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickActivity() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: darkGreen.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('Choose Activity'),
                  style: GoogleFonts.outfit(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _activitiesOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final option = _activitiesOptions[index];
                      final isSelected = option == _selectedActivity;

                      return Material(
                        color:
                            isSelected
                                ? darkGreen.withValues(alpha: 0.08)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            context.tr(option),
                            style: TextStyle(
                              color: darkGreen,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: darkGreen,
                                  )
                                  : null,
                          onTap: () => Navigator.pop(context, option),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _selectedActivity = selected);
    }
  }

  Future<void> _submit() async {
    if (_selectedActivity == null || _image == null) {
      showAppSnackBar(
        context,
        context.tr('Please select an activity and take a photo first.'),
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final imageBytes = _imageBytes;
      if (imageBytes == null) {
        throw Exception(context.tr('Image data is missing. Please try taking the photo again.'));
      }

      if (!mounted) return;

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final activityProvider = context.read<ActivityProvider>();
      final error = await activityProvider.submitManualActivity(
        activityTitle: _selectedActivity!,
        dateTime: dateTime,
        imageBytes: imageBytes,
        filename: _image?.name,
      );

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      if (error != null) {
        showAppSnackBar(
          context,
          context.tr(error),
          backgroundColor: Colors.red.shade700,
        );
        return;
      }

      _showSuccessDialog(
        activityProvider.lastSubmittedStatus == ActivityStatus.approved,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      showAppSnackBar(
        context,
        context.loc.analysisFailed(error),
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  void _showSuccessDialog(bool verified) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(
          verified ? Icons.check_circle : Icons.hourglass_empty,
          color: darkGreen,
          size: 50,
        ),
        content: Text(
          verified
              ? context.tr('AI verification matched your report. Points were added immediately.')
              : context.tr('Your report was submitted successfully and is waiting for admin review.'),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(
              context.tr('Awesome!'),
              style: const TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreenBg,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: lightGreenBg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: darkGreen, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      context.tr('Manual Report'),
                      style: GoogleFonts.outfit(
                        color: darkGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: subtleGreenBorder),
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, color: darkGreen, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                context.tr('Tap to take a photo'),
                                style: TextStyle(
                                  color: darkGreen.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _imageBytes == null
                                ? const SizedBox.shrink()
                                : Image.memory(_imageBytes!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildSectionLabel(context.tr('What did you do?')),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickActivity,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(
                              _selectedActivity ?? 'Choose Activity',
                            ),
                            style: TextStyle(
                              color:
                                  _selectedActivity == null
                                      ? darkGreen.withValues(alpha: 0.8)
                                      : darkGreen,
                              fontSize: 14,
                              fontWeight:
                                  _selectedActivity == null
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: darkGreen,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildPickerTile(
                      icon: Icons.calendar_today,
                      label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                      onTap: _pickDate,
                    ),
                    const SizedBox(width: 10),
                    _buildPickerTile(
                      icon: Icons.access_time,
                      label: _selectedTime.format(context),
                      onTap: _pickTime,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isAnalyzing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            context.tr('Submit Report'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('Reports that cannot be verified automatically will wait for admin review.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkGreen.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: darkGreen,
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: darkGreen, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
