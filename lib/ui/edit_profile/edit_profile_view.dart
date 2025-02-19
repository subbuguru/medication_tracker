import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/core/primary_button.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/privacy_policy_button.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pcpController = TextEditingController();
  final TextEditingController _healthConditionsController =
      TextEditingController();
  final TextEditingController _pharmacyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final MaskTextInputFormatter _phoneNumberFormatter = MaskTextInputFormatter(
      mask: '(###) ###-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    super.initState();
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profile = profileProvider.selectedProfile;
    if (profile != null) {
      _nameController.text = profile.name;
      _dobController.text = profile.dob;
      _pcpController.text = profile.pcp;
      _healthConditionsController.text = profile.healthConditions;
      _pharmacyController.text = profile.pharmacy;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentProfile =
          Provider.of<ProfileProvider>(context, listen: false).selectedProfile;
      if (currentProfile?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No profile selected to update'),
          ),
        );
        return;
      }

      final profile = UserProfile(
        id: currentProfile!.id,
        name: _nameController.text,
        dob: _dobController.text,
        pcp: _pcpController.text,
        healthConditions: _healthConditionsController.text,
        pharmacy: _pharmacyController.text,
      );

      try {
        await Provider.of<ProfileProvider>(context, listen: false)
            .updateProfile(profile);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile successfully updated'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.colorScheme.surface, // Set scaffold background color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'Your Profile',
          showBackButton: Navigator.canPop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Personal Information Subheading
                          Text(
                            'Personal Information',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration('Name'),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Date of Birth Field
                          TextFormField(
                            controller: _dobController,
                            decoration: _inputDecoration('Date of Birth'),
                            onTap: () => _selectDate(context),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Date of Birth is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Health Information Subheading
                          Text(
                            'Health Information',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Primary Care Physician Field
                          TextFormField(
                            controller: _pcpController,
                            decoration: _inputDecoration(
                                'Primary Care Physician (optional)'),
                          ),
                          const SizedBox(height: 8),

                          // Pharmacy Phone Field
                          TextFormField(
                            controller: _pharmacyController,
                            decoration:
                                _inputDecoration('Pharmacy Phone (optional)'),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_phoneNumberFormatter],
                          ),
                          const SizedBox(height: 8),

                          // Health Conditions Field
                          TextFormField(
                            controller: _healthConditionsController,
                            decoration: _inputDecoration(
                                'Health Conditions (optional)'),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                          const SizedBox(height: 24),

                          // Privacy Policy Button
                          const PrivacyPolicyButton(),
                          const SizedBox(height: 8),

                          // Save Profile Button
                          PrimaryButton(
                            title: "Save Profile",
                            onTap: _saveProfile,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor:
          Theme.of(context).colorScheme.secondaryContainer, // Background color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none, // Remove border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }
}
