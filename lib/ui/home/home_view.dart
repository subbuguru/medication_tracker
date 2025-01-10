import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/edit_medication/edit_medication_view.dart';
import 'package:medication_tracker/ui/search/fda_search_view.dart';
import 'package:medication_tracker/ui/home/med_tile.dart';
import 'package:medication_tracker/ui/home/nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String nameOrNA(String? text) {
    if (text == null || text.isEmpty) {
      return "Name N/A";
    }
    return text;
  }

  String dOBOrNA(String? text) {
    if (text == null || text.isEmpty) {
      return "N/A";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile header section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: theme.colorScheme.secondary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          nameOrNA(profileProvider.selectedProfile?.name),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.onSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          minFontSize: 18,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dOBOrNA(profileProvider.selectedProfile?.dob),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),

            // Medication list section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Consumer<MedicationProvider>(
                        builder: (context, medicationProvider, child) {
                          if (medicationProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (medicationProvider.errorMessage.isNotEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  medicationProvider.errorMessage,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (medicationProvider.medications.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "No medications. Add by pressing the + button below.",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: medicationProvider.medications.length,
                            itemBuilder: (context, index) {
                              final medication =
                                  medicationProvider.medications[index];
                              return GestureDetector(
                                onTap: () async {
                                  try {
                                    if (!context.mounted) return;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditMedicationPage(
                                                medication: medication),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to edit medication: $e'),
                                      ),
                                    );
                                  }
                                },
                                child: MedicationTile(medication: medication),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FDASearchPage()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        elevation: 6,
        shape: const StadiumBorder(),
        label: Text(
          'Add',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
