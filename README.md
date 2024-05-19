# medication_tracker


CURRENTLY: MIGRATING TO A MULTIPLE PROFILE SYSTEM! & WORKING ON A SCANNING SYSTEM

## Multiple Profiles - High level overview

We need to first create a persistent storage system of the current profile id. Currently I am thinking of shared_preferences.

Then we need to modify profileProvider to take advantage of this and provide the current profile to the UI

Third, we need to use the profile provided from the provider to modify medicationProvider to be able to provide a correct
medication list for that given profile

We also need to create a UI system to switch between profiles

