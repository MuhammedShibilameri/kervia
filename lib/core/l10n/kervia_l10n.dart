import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLanguage {
  AppLanguage._();

  static final ValueNotifier<String> notifier = ValueNotifier<String>('en');

  static String get current => notifier.value;
  static bool get isMalayalam => current == 'ml';
  static Locale get locale => Locale(current);

  static void set(String lang) {
    if (lang == 'ml' || lang == 'en') notifier.value = lang;
  }

  static void toggle() => set(isMalayalam ? 'en' : 'ml');

  /// Rebuilds the app whenever language or theme changes.
  static Listenable get rebuildListenable => notifier;
}

class AppThemeMode {
  AppThemeMode._();

  static final ValueNotifier<ThemeMode> notifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static ThemeMode get mode => notifier.value;
  static bool get isDark => mode == ThemeMode.dark;
  static Listenable get rebuildListenable => notifier;

  static void set(ThemeMode m) => notifier.value = m;
  static void toggle() => set(isDark ? ThemeMode.light : ThemeMode.dark);
}

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ml'),
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations localizationsFromLocale(Locale locale) =>
      AppLocalizations(locale);

  bool get isMalayalam => locale.languageCode == 'ml';

  String tr(String key) =>
      isMalayalam ? (_mlTranslations[key] ?? key) : key;

  static const Map<String, String> _mlTranslations = {
    // Common
    'Welcome back': 'സ്വാഗതം',
    'Continue': 'തുടരുക',
    'Back': 'പിൻകാഴ്ച',
    'Save': 'സംരക്ഷിക്കുക',
    'Saving…': 'സംരക്ഷിക്കുന്നു…',
    'Search': 'തിരയുക',
    'Search…': 'തിരയുക…',
    'Resume /\nProfile': 'റെസ്യൂം /\nപ്രൊഫൈൽ',
    'Edit': 'തിരുത്തുക',
    'Cancel': 'റദ്ദാക്കുക',
    'Submit': 'സമർപ്പിക്കുക',
    'Preview': 'പ്രിവ്യൂ',
    'Next': 'അടുത്തത്',
    'Remove': 'നീക്കം ചെയ്യുക',
    'Filters': 'ഫിൽട്ടറുകൾ',
    'All': 'എല്ലാം',
    'Save Changes': 'മാറ്റങ്ങൾ സംരക്ഷിക്കുക',
    'Home': 'ഹോം',
    'Profile': 'പ്രൊഫൈൽ',
    'Application': 'അപേക്ഷ',
    'Applications': 'അപേക്ഷകൾ',
    'Interviews': 'ഇന്റർവ്യൂകൾ',
    'Invitation': 'ക്ഷണം',
    'Language': 'ഭാഷ',
    'Theme': 'തീം',
    'Notifications': 'അറിയിപ്പുകൾ',
    'Enabled': 'പ്രവർത്തനക്ഷമം',
    'Disabled': 'പ്രവർത്തനരഹിതം',
    'Light': 'ലൈറ്റ്',
    'Dark': 'ഡാർക്ക്',
    'EN': 'EN',
    'ML': 'ML',

    // Sign In
    'Sign In': 'സൈൻ ഇൻ',
    'Sign in to Kervia': 'കേർവിയയിലേക്ക് സൈൻ ഇൻ ചെയ്യുക',
    'Phone number': 'ഫോൺ നമ്പർ',
    'Enter your phone number': 'നിങ്ങളുടെ ഫോൺ നമ്പർ നൽകുക',
    'Continue with Google': 'ഗൂഗിൾ ഉപയോഗിച്ച് തുടരുക',
    'Enter your credentials to continue': 'തുടരാൻ നിങ്ങളുടെ ക്രെഡൻഷ്യലുകൾ നൽകുക',
    'Please enter your phone number': 'നിങ്ങളുടെ ഫോൺ നമ്പർ നൽകുക',
    'Send OTP': 'OTP അയയ്ക്കുക',
    'or': 'അല്ലെങ്കിൽ',
    "By continuing, you agree to Kervia's Terms of Service and Privacy Policy":
        'തുടരുന്നതിലൂടെ, കേർവിയയുടെ സേവന നിബന്ധനകളും സ്വകാര്യതാ നയവും നിങ്ങൾ അംഗീകരിക്കുന്നു',
    'Verify OTP': 'OTP പരിശോധിക്കുക',
    'Please enter all 6 digits of the code': 'കോഡിന്റെ 6 അക്കങ്ങളും നൽകുക',
    'Back to Sign In': 'സൈൻ ഇൻ ചെയ്യുന്നതിലേക്ക് മടങ്ങുക',
    'Verify Your Number': 'നിങ്ങളുടെ നമ്പർ പരിശോധിക്കുക',
    "We've sent a 6-digit code to": '6 അക്ക കോഡ് അയച്ചു',
    'Change': 'മാറ്റുക',
    'Verify & Continue': 'പരിശോധിച്ച് തുടരുക',
    "Didn't receive the code? Resend in": "കോഡ് ലഭിച്ചില്ലേ? വീണ്ടും അയയ്ക്കുക",
    'Resend Code': 'കോഡ് വീണ്ടും അയയ്ക്കുക',
    'Having trouble? Contact Support': 'പ്രശ്നമുണ്ടോ? സപ്പോർട്ടിനെ ബന്ധപ്പെടുക',
    'Elevate your career with Kervia': 'കേർവിയയുമായി നിങ്ങളുടെ കരിയർ ഉയർത്തുക',
    'Join the premier network of professionals and recruiters. Authenticate your identity to access premium features.':
        'പ്രൊഫഷണലുകളുടെയും റിക്രൂട്ടർമാരുടെയും മുൻനിര നെറ്റ്‌വർക്കിൽ ചേരുക. പ്രീമിയം ഫീച്ചറുകൾ ആക്സസ് ചെയ്യാൻ നിങ്ങളുടെ ഐഡന്റിറ്റി പരിശോധിക്കുക.',
    'Verified Profile Status': 'പരിശോധിച്ച പ്രൊഫൈൽ സ്റ്റാറ്റസ്',
    'Enhanced Security with Multi-Factor': 'മൾട്ടി-ഫാക്ടർ സുരക്ഷ',
    "The premier professional network connecting elite talent with top-tier companies. Whether you're searching for your next big role or building a world-class team, Kervia provides the tools you need to succeed.":
        'മികച്ച ടാലന്റുകളെ മുൻനിര കമ്പനികളുമായി ബന്ധിപ്പിക്കുന്ന പ്രമുഖ പ്രൊഫഷണൽ നെറ്റ്‌വർക്ക്. നിങ്ങളുടെ അടുത്ത വലിയ റോൾ തേടുകയാണെങ്കിലും ലോകോത്തര ടീം കെട്ടിപ്പടുക്കുകയാണെങ്കിലും, വിജയിക്കാൻ ആവശ്യമായ ഉപകരണങ്ങൾ കേർവിയ നൽകുന്നു.',
    'Verified Professional Profiles': 'പരിശോധിച്ച പ്രൊഫഷണൽ പ്രൊഫൈലുകൾ',
    'Curated High-Value Job Postings': 'ക്യൂറേറ്റഡ് ഉയർന്ന മൂല്യമുള്ള ജോലി പോസ്റ്റിംഗുകൾ',
    'AI-Powered Talent Matching': 'AI-പവർഡ് ടാലന്റ് മാച്ചിംഗ്',
    'OTP sent to': 'OTP അയച്ചു',
    'Did not receive?': 'ലഭിച്ചില്ലേ?',
    'Resend OTP': 'OTP വീണ്ടും അയയ്ക്കുക',

    // Roles
    'Choose your role': 'നിങ്ങളുടെ റോൾ തിരഞ്ഞെടുക്കുക',
    'Choose Your Path': 'നിങ്ങളുടെ പാത തിരഞ്ഞെടുക്കുക',
    "Join Kervia's professional network today. Select how you'd like to use our platform to get started.":
        'ഇന്ന് തന്നെ കേർവിയയുടെ പ്രൊഫഷണൽ നെറ്റ്‌വർക്കിൽ ചേരുക. ആരംഭിക്കുന്നതിന് നിങ്ങൾ എങ്ങനെ ഞങ്ങളുടെ പ്ലാറ്റ്ഫോം ഉപയോഗിക്കണമെന്ന് തിരഞ്ഞെടുക്കുക.',
    'Register as Job Seeker': 'ജോലിക്കാരനായി രജിസ്റ്റർ ചെയ്യുക',
    'Find your dream job and grow your career. Access exclusive opportunities, build your professional profile, and connect with top recruiters.':
        'നിങ്ങളുടെ സ്വപ്ന ജോലി കണ്ടെത്തി കരിയർ മെച്ചപ്പെടുത്തുക. പ്രത്യേക അവസരങ്ങൾ ആക്സസ് ചെയ്യുക, പ്രൊഫഷണൽ പ്രൊഫൈൽ നിർമ്മിക്കുക, മികച്ച റിക്രൂട്ടർമാരുമായി ബന്ധപ്പെടുക.',
    'Register as Company': 'കമ്പനിയായി രജിസ്റ്റർ ചെയ്യുക',
    'Company onboarding selected. Coming next!':
        'കമ്പനി ഓൺബോർഡിംഗ് തിരഞ്ഞെടുത്തു. അടുത്തതായി വരുന്നു!',
    'Terms of Service': 'സേവന നിബന്ധനകൾ',
    'Help Center': 'സഹായ കേന്ദ്രം',
    'Contact': 'ബന്ധപ്പെടുക',
    'Kervia © 2026 Kervia Professional. All rights reserved.':
        'കേർവിയ © 2026 കേർവിയ പ്രൊഫഷണൽ. എല്ലാ അവകാശങ്ങളും നിക്ഷിപ്തം.',
    'I am a Job Seeker': 'ഞാൻ ഒരു ജോലിക്കാരനാണ്',
    'I am a Company': 'ഞാൻ ഒരു കമ്പനിയാണ്',
    'Find jobs that match your skills and kickstart your career.':
        'നിങ്ങളുടെ കഴിവുകൾക്ക് അനുയോജ്യമായ ജോലികൾ കണ്ടെത്തി നിങ്ങളുടെ കരിയർ ആരംഭിക്കുക.',
    'Hire top talent and build your winning team. Post jobs, search our extensive candidate database, and manage your recruitment pipeline efficiently.':
        'മികച്ച ടാലന്റുകളെ നിയമിക്കുകയും മികച്ച ടീം കെട്ടിപ്പടുക്കുകയും ചെയ്യുക. ജോലികൾ പോസ്റ്റ് ചെയ്യുക, ഞങ്ങളുടെ വിപുലമായ കാൻഡിഡേറ്റ് ഡാറ്റാബേസ് തിരയുക, നിങ്ങളുടെ റിക്രൂട്ട്മെന്റ് പൈപ്പ്‌ലൈൻ കാര്യക്ഷമമായി കൈകാര്യം ചെയ്യുക.',

    // Registration steps
    'Personal Details': 'വ്യക്തിഗത വിവരങ്ങൾ',
    'Professional Details': 'പ്രൊഫഷണൽ വിവരങ്ങൾ',
    'Skills & Preferences': 'കഴിവുകളും മുൻഗണനകളും',
    'Resume & Video': 'റെസ്യൂമും വീഡിയോയും',
    'Step 1': 'ഘട്ടം 1',
    'Step 2': 'ഘട്ടം 2',
    'Step 3': 'ഘട്ടം 3',
    'Review & Submit': 'അവലോകനം & സമർപ്പിക്കുക',

    // Home
    'Profile Strength': 'പ്രൊഫൈൽ ശക്തി',
    'Keep your profile updated for better job matches.':
        'മികച്ച ജോലി ലഭിക്കാൻ നിങ്ങളുടെ പ്രൊഫൈൽ കാലികമായി നിലനിർത്തുക.',
    'My preferences': 'എന്റെ മുൻഗണനകൾ',
    'District': 'ജില്ല',
    'Taluk': 'താലൂക്ക്',
    'Local body': 'തദ്ദേശ സ്ഥാപനം',
    'Job category': 'ജോലി വിഭാഗം',
    'Job title or company': 'ജോലി തലക്കെട്ട് അല്ലെങ്കിൽ കമ്പനി',
    'My Applications': 'എന്റെ അപേക്ഷകൾ',
    'Saved Jobs': 'സംരക്ഷിച്ച ജോലികൾ',
    'Resume / Profile': 'റെസ്യൂം / പ്രൊഫൈൽ',
    'My Interviews': 'എന്റെ ഇന്റർവ്യൂകൾ',
    'Companies that invite you to an interview appear here.':
        'നിങ്ങളെ ഇന്റർവ്യൂവിന് ക്ഷണിക്കുന്ന കമ്പനികൾ ഇവിടെ കാണാം.',
    'No interviews yet.': 'ഇതുവരെ ഇന്റർവ്യൂകളൊന്നുമില്ല.',
    'When a company moves your application to the interview stage, it will appear here.':
        'ഒരു കമ്പനി നിങ്ങളുടെ അപേക്ഷ ഇന്റർവ്യൂ ഘട്ടത്തിലേക്ക് മാറ്റുമ്പോൾ, അത് ഇവിടെ കാണാം.',
    'Profile not found.': 'പ്രൊഫൈൽ കണ്ടെത്തിയില്ല.',
    'Could not load profile.': 'പ്രൊഫൈൽ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല.',
    'Messages': 'സന്ദേശങ്ങൾ',
    'Chat with candidates who applied to your jobs.':
        'നിങ്ങളുടെ ജോലികൾക്ക് അപേക്ഷിച്ച സ്ഥാനാർത്ഥികളുമായി ചാറ്റ് ചെയ്യുക.',
    'Chat with companies about your applications.':
        'നിങ്ങളുടെ അപേക്ഷകളെക്കുറിച്ച് കമ്പനികളുമായി ചാറ്റ് ചെയ്യുക.',
    'Archived Messages': 'ആർക്കൈവ് ചെയ്ത സന്ദേശങ്ങൾ',
    'Spam (Reported)': 'സ്പാം (റിപ്പോർട്ട് ചെയ്തത്)',
    'Conversation archived.': 'സംഭാഷണം ആർക്കൈവ് ചെയ്തു.',
    'Conversation deleted.': 'സംഭാഷണം ഇല്ലാതാക്കി.',
    'Restored to inbox.': 'ഇൻബോക്സിലേക്ക് പുനഃസ്ഥാപിച്ചു.',
    'Reported as spam.': 'സ്പാം ആയി റിപ്പോർട്ട് ചെയ്തു.',
    'Unspammed.': 'സ്പാം നീക്കി.',
    'No archived conversations.': 'ആർക്കൈവ് ചെയ്ത സംഭാഷണങ്ങളൊന്നുമില്ല.',
    'When you archive a conversation it will appear here so you can restore it.':
        'നിങ്ങൾ ഒരു സംഭാഷണം ആർക്കൈവ് ചെയ്യുമ്പോൾ അത് ഇവിടെ ദൃശ്യമാകും, അത് പുനഃസ്ഥാപിക്കാം.',
    'No spam conversations.': 'സ്പാം സംഭാഷണങ്ങളൊന്നുമില്ല.',
    'If you mark a conversation as spam it will move here and be removed from your inbox.':
        'നിങ്ങൾ ഒരു സംഭാഷണം സ്പാം ആയി അടയാളപ്പെടുത്തുകയാണെങ്കിൽ, അത് ഇവിടേക്ക് നീങ്ങുകയും നിങ്ങളുടെ ഇൻബോക്സിൽ നിന്ന് നീക്കം ചെയ്യപ്പെടുകയും ചെയ്യും.',
    'Delete conversation?': 'സംഭാഷണം ഇല്ലാതാക്കണോ?',
    'This removes the conversation from your messages. The other person can still see it.':
        'ഇത് നിങ്ങളുടെ സന്ദേശങ്ങളിൽ നിന്ന് സംഭാഷണം നീക്കം ചെയ്യും. മറ്റേയാൾക്ക് ഇത് ഇപ്പോഴും കാണാൻ കഴിയും.',
    'Could not archive the conversation.': 'സംഭാഷണം ആർക്കൈവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.',
    'Could not report the conversation.': 'സംഭാഷണം റിപ്പോർട്ട് ചെയ്യാൻ കഴിഞ്ഞില്ല.',
    'Could not update the conversation.': 'സംഭാഷണം അപ്ഡേറ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല.',
    'Could not delete the conversation.': 'സംഭാഷണം ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല.',
    'Skills': 'നൈപുണ്യങ്ങൾ',
    'Jobs for you': 'നിങ്ങൾക്കുള്ള ജോലികൾ',
    'Based on your saved profile preferences and current filters.':
        'നിങ്ങളുടെ സംരക്ഷിച്ച പ്രൊഫൈൽ മുൻഗണനകളും നിലവിലെ ഫിൽട്ടറുകളും അടിസ്ഥാനമാക്കി.',
    'jobs': 'ജോലികൾ',
    'No jobs match your filters.': 'നിങ്ങളുടെ ഫിൽട്ടറുകളുമായി ജോലികൾ ഒന്നും പൊരുത്തപ്പെടുന്നില്ല.',
    'Vacancies': 'ഒഴിവുകൾ',
    'Posted': 'പോസ്റ്റ് ചെയ്തത്',
    'Last date to apply': 'അപേക്ഷിക്കാനുള്ള അവസാന തീയതി',
    'View & Apply': 'കാണുക & അപേക്ഷിക്കുക',
    'Already Applied': 'ഇതിനകം അപേക്ഷിച്ചു',
    'coming soon': 'താമസിയാതെ വരും',
    'Job Details': 'ജോലി വിവരങ്ങൾ',
    'About this job': 'ഈ ജോലിയെക്കുറിച്ച്',
    'Apply Now': 'ഇപ്പോൾ അപേക്ഷിക്കുക',
    'Applying…': 'അപേക്ഷിക്കുന്നു…',
    'Application submitted successfully!': 'അപേക്ഷ വിജയകരമായി സമർപ്പിച്ചു!',
    'This is a demo job listed to showcase the Kervia job feed. Full descriptions, screening questions and recruiter contact details will appear here once real jobs are added by employers.':
        'കേർവിയ ജോബ് ഫീഡ് പ്രദർശിപ്പിക്കുന്നതിനായി ലിസ്റ്റ് ചെയ്ത ഒരു ഡെമോ ജോലിയാണിത്. തൊഴിലുടമകൾ യഥാർത്ഥ ജോലികൾ ചേർക്കുമ്പോൾ പൂർണ്ണ വിവരണങ്ങളും സ്ക്രീനിംഗ് ചോദ്യങ്ങളും റിക്രൂട്ടർ കോൺടാക്റ്റ് വിശദാംശങ്ങളും ഇവിടെ ദൃശ്യമാകും.',

    // Profile menu
    'Job Seeker': 'ജോലിക്കാരൻ',
    'ACCOUNT': 'അക്കൗണ്ട്',
    'Professional Details → sub': 'പ്രൊഫഷണൽ വിവരങ്ങൾ',
    'Skills & Preferences → sub': 'കഴിവുകളും മുൻഗണനകളും',
    'SETTINGS': 'ക്രമീകരണങ്ങൾ',
    'ABOUT': 'കുറിച്ച്',
    'Privacy Policy': 'സ്വകാര്യതാ നയം',
    'Terms & Conditions': 'നിയമങ്ങളും വ്യവസ്ഥകളും',
    'About Kervia': 'കേർവിയയെ കുറിച്ച്',
    'Logout': 'ലോഗൗട്ട്',
    'Log out': 'ലോഗ് ഔട്ട്',
    'Are you sure you want to log out?': 'ലോഗ് ഔട്ട് ചെയ്യണോ?',
    'Personal Information': 'വ്യക്തിഗത വിവരങ്ങൾ',
    'Full Name': 'പൂർണ്ണമായ പേര്',
    'Date of Birth': 'ജനന തീയതി',
    'Gender': 'ലിംഗഭേദം',
    'Phone Number': 'ഫോൺ നമ്പർ',
    'Email Address': 'ഇമെയിൽ വിലാസം',
    'Current Address': 'നിലവിലെ വിലാസം',
    'State': 'സംസ്ഥാനം',
    'Regional Details': 'പ്രാദേശിക വിവരങ്ങൾ',
    'Local Body': 'തദ്ദേശ സ്ഥാപനം',
    'Highest Qualification': 'ഉയർന്ന വിദ്യാഭ്യാസ യോഗ്യത',
    'Current Occupation': 'നിലവിലെ തൊഴിൽ',
    'Years of Experience': 'പ്രവൃത്തിപരിചയം (വർഷം)',
    'Current Salary': 'നിലവിലെ ശമ്പളം',
    'Expected Salary': 'പ്രതീക്ഷിക്കുന്ന ശമ്പളം',
    'Salary Period': 'ശമ്പള കാലയളവ്',
    'Key Skills': 'പ്രധാന കഴിവുകൾ',
    'Languages Spoken': 'സംസാരിക്കുന്ന ഭാഷകൾ',
    'Preferred Work Mode': 'മുൻഗണനയുള്ള ജോലി രീതി',
    'Employment Types': 'തൊഴിൽ തരങ്ങൾ',
    'Preferred Job Roles': 'മുൻഗണനയുള്ള ജോലി റോളുകൾ',
    'Target Locations': 'ലക്ഷ്യ സ്ഥലങ്ങൾ',
    'Edit Personal Details': 'വ്യക്തിഗത വിവരങ്ങൾ തിരുത്തുക',
    'Edit Professional Details': 'പ്രൊഫഷണൽ വിവരങ്ങൾ തിരുത്തുക',
    'Edit Skills & Preferences': 'കഴിവുകളും മുൻഗണനകളും തിരുത്തുക',
    'Edit Resume & Video': 'റെസ്യൂമും വീഡിയോയും തിരുത്തുക',
    'No resume added yet.': 'റെസ്യൂം ചേർത്തിട്ടില്ല.',
    'No intro video added yet.': 'ഇന്റ്രോ വീഡിയോ ചേർത്തിട്ടില്ല.',
    'Add / Change Resume or Video': 'റെസ്യൂം അല്ലെങ്കിൽ വീഡിയോ ചേർക്കുക / മാറ്റുക',
    'Preview / Download': 'പ്രിവ്യൂ / ഡൗൺലോഡ്',
    'Play Video': 'വീഡിയോ പ്ലേ ചെയ്യുക',

    // Settings about
    'Select your preferred language.': 'നിങ്ങളുടെ ഇഷ്ടപ്പെട്ട ഭാഷ തിരഞ്ഞെടുക്കുക.',
    'Choose between light and dark theme.': 'ലൈറ്റ്, ഡാർക്ക് തീമുകൾക്കിടയിൽ തിരഞ്ഞെടുക്കുക.',
    'Notifications keep you informed about new jobs and updates.':
        'പുതിയ ജോലികളെക്കുറിച്ചും അപ്ഡേറ്റുകളെക്കുറിച്ചും അറിയിപ്പുകൾ നിങ്ങളെ അറിയിക്കുന്നു.',
    'English': 'ഇംഗ്ലീഷ്',
    'Close': 'അടയ്ക്കുക',
    'Name, contact, location': 'പേര്, ബന്ധപ്പെടാനുള്ള വിവരങ്ങൾ, സ്ഥലം',
    'Qualification, experience, salary':
        'വിദ്യാഭ്യാസ യോഗ്യത, പ്രവൃത്തിപരിചയം, ശമ്പളം',
    'Skills, languages, job preferences':
        'കഴിവുകൾ, ഭാഷകൾ, ജോലി മുൻഗണനകൾ',
    'Resume, introduction video': 'റെസ്യൂം, ഇന്റ്രോ വീഡിയോ',
    '© 2026 Kervia • Candidate Portal': '© 2026 കേർവിയ • കാൻഡിഡേറ്റ് പോർട്ടൽ',
    'Location not set': 'സ്ഥലം സജ്ജീകരിച്ചിട്ടില്ല',
    'User': 'ഉപയോക്താവ്',
    'Kervia stores and handles your professional data securely. Your contact details, resume and preferences are used only to match you with recruiters. You can control discoverability from your settings.':
        'നിങ്ങളുടെ പ്രൊഫഷണൽ ഡാറ്റ കേർവിയ സുരക്ഷിതമായി സൂക്ഷിക്കുകയും കൈകാര്യം ചെയ്യുകയും ചെയ്യുന്നു. നിങ്ങളുടെ കോൺടാക്റ്റ് വിവരങ്ങൾ, റെസ്യൂം, മുൻഗണനകൾ എന്നിവ റിക്രൂട്ടർമാരുമായി നിങ്ങളെ ബന്ധിപ്പിക്കാൻ മാത്രമാണ് ഉപയോഗിക്കുന്നത്.',
    'By using Kervia you agree to provide accurate professional information. Kervia may terminate profiles that violate our policies. Use of the platform is at your own risk.':
        'കേർവിയ ഉപയോഗിക്കുന്നതിലൂടെ കൃത്യമായ പ്രൊഫഷണൽ വിവരങ്ങൾ നൽകാൻ നിങ്ങൾ സമ്മതിക്കുന്നു. ഞങ്ങളുടെ നയങ്ങൾ ലംഘിക്കുന്ന പ്രൊഫൈലുകൾ കേർവിയ അവസാനിപ്പിച്ചേക്കാം. പ്ലാറ്റ്ഫോം ഉപയോഗം നിങ്ങളുടെ സ്വന്തം ഉത്തരവാദിത്തത്തിലാണ്.',
    'Kervia is a candidate portal that helps professionals get discovered by recruiters. v1.0.0':
        'പ്രൊഫഷണലുകളെ റിക്രൂട്ടർമാർ കണ്ടെത്താൻ സഹായിക്കുന്ന ഒരു കാൻഡിഡേറ്റ് പോർട്ടലാണ് കേർവിയ. v1.0.0',
    'Complete Your Profile': 'നിങ്ങളുടെ പ്രൊഫൈൽ പൂർത്തിയാക്കുക',
    'Finish your registration so recruiters can discover your profile, resume and preferences.':
        'റിക്രൂട്ടർമാർക്ക് നിങ്ങളുടെ പ്രൊഫൈൽ, റെസ്യൂം, മുൻഗണനകൾ എന്നിവ കണ്ടെത്താൻ നിങ്ങളുടെ രജിസ്ട്രേഷൻ പൂർത്തിയാക്കുക.',
    'Complete Registration': 'രജിസ്ട്രേഷൻ പൂർത്തിയാക്കുക',
    'Your upcoming interviews will appear here.':
        'നിങ്ങളുടെ വരാനിരിക്കുന്ന ഇന്റർവ്യൂകൾ ഇവിടെ ദൃശ്യമാകും.',
    'Recruiter invitations will appear here.':
        'റിക്രൂട്ടർ ക്ഷണങ്ങൾ ഇവിടെ ദൃശ്യമാകും.',
    'All Districts': 'എല്ലാ ജില്ലകൾ',
    'All Taluks': 'എല്ലാ താലൂക്കുകൾ',
    'All Local bodies': 'എല്ലാ തദ്ദേശ സ്ഥാപനങ്ങൾ',
    'All Categories': 'എല്ലാ വിഭാഗങ്ങൾ',
    'Use': 'ഇത് ഉപയോഗിക്കുക',
    'Quick Actions': 'ദ്രുത പ്രവർത്തനങ്ങൾ',
    'updated.': 'അപ്ഡേറ്റ് ചെയ്തു.',
    'No file added': 'ഫയൽ ചേർത്തിട്ടില്ല',
    'Add Skill': 'നൈപുണ്യം ചേർക്കുക',
    'Add': 'ചേർക്കുക',
    'Tap to add a suggested skill': 'ഒരു നിർദ്ദേശിത നൈപുണ്യം ചേർക്കാൻ ടാപ്പ് ചെയ്യുക',
    'Select': 'തിരഞ്ഞെടുക്കുക',
    'Select Date of Birth': 'ജനന തീയതി തിരഞ്ഞെടുക്കുക',
    'Could not save changes.': 'മാറ്റങ്ങൾ സംരക്ഷിക്കാൻ കഴിഞ്ഞില്ല.',
    'Full Name *': 'മുഴുവൻ പേര് *',
    'Email Address *': 'ഇമെയിൽ വിലാസം *',
    'Phone Number *': 'ഫോൺ നമ്പർ *',
    'Gender *': 'ലിംഗഭേദം *',
    'State *': 'സംസ്ഥാനം *',
    'District *': 'ജില്ല *',
    'Taluk *': 'താലൂക്ക് *',
    'Panchayat / Municipality *': 'പഞ്ചായത്ത് / മുനിസിപ്പാലിറ്റി *',
    'Highest Qualification *': 'ഏറ്റവും ഉയർന്ന യോഗ്യത *',
    'Current Occupation *': 'നിലവിലെ തൊഴിൽ *',
    'e.g. Jane Doe': 'ഉദാ. ജെയ്ൻ ഡോ',
    'e.g. jane.doe@example.com': 'ഉദാ. jane.doe@example.com',
    'e.g. +91 98765 43210': 'ഉദാ. +91 98765 43210',
    'House no., street, city, PIN': 'വീട് നമ്പർ, തെരുവ്, നഗരം, പിൻ',
    'Select a state': 'ഒരു സംസ്ഥാനം തിരഞ്ഞെടുക്കുക',
    'Select a district': 'ഒരു ജില്ല തിരഞ്ഞെടുക്കുക',
    'Select a taluk': 'ഒരു താലൂക്ക് തിരഞ്ഞെടുക്കുക',
    'Select panchayat': 'പഞ്ചായത്ത് തിരഞ്ഞെടുക്കുക',
    'Select your qualification': 'നിങ്ങളുടെ യോഗ്യത തിരഞ്ഞെടുക്കുക',
    'Select your occupation': 'നിങ്ങളുടെ തൊഴിൽ തിരഞ്ഞെടുക്കുക',
    'e.g. 5': 'ഉദാ. 5',
    'e.g. Flutter, Python, Project Management...': 'ഉദാ. Flutter, Python, Project Management...',
    'e.g. English, Malayalam': 'ഉദാ. English, Malayalam',
    'e.g. Software Development, Marketing... (comma separated)':
        'ഉദാ. Software Development, Marketing... (കോമയാൽ വേർതിരിക്കുക)',
    'e.g. Kochi, Calicut, Remote': 'ഉദാ. Kochi, Calicut, Remote',
    'Submitted': 'സമർപ്പിച്ചു',
    'In Review': 'അവലോകനത്തിലാണ്',
    'Shortlisted': 'ഷോർട്ട്ലിസ്റ്റ് ചെയ്തു',
    'Interview Stage': 'ഇന്റർവ്യൂ ഘട്ടം',
    'Rejected': 'നിരസിച്ചു',
    'Withdrawn': 'പിൻവലിച്ചു',
    'Hired': 'ജോലി ലഭിച്ചു',
    'Applied on: ': 'അപേക്ഷിച്ച തീയതി: ',
    'Application deadline: ': 'അപേക്ഷാ അവസാന തീയതി: ',
    'Filter by status': 'സ്റ്റാറ്റസ് അനുസരിച്ച് ഫിൽട്ടർ ചെയ്യുക',
    'Track the status of every job you applied for.':
        'നിങ്ങൾ അപേക്ഷിച്ച എല്ലാ ജോലികളുടെയും സ്റ്റാറ്റസ് ട്രാക്ക് ചെയ്യുക.',
    'No': 'ഇല്ല',
    'Switched tab to index': 'ടാബിലേക്ക് മാറി',
    'Application details': 'അപേക്ഷാ വിശദാംശങ്ങൾ',
    'Application status': 'അപേക്ഷാ സ്റ്റാറ്റസ്',
    'APPLIED ON': 'അപേക്ഷിച്ച തീയതി',
    'SOURCE': 'ഉറവിടം',
    'LAST UPDATED': 'അവസാനം അപ്ഡേറ്റ് ചെയ്തത്',
    'JOB STATUS': 'ജോലി സ്റ്റാറ്റസ്',
    'OCCUPATION': 'തൊഴിൽ',
    'EMPLOYMENT TYPE': 'തൊഴിൽ തരം',
    'WORK MODE': 'ജോലി രീതി',
    'SALARY': 'ശമ്പളം',
    'EXPERIENCE': 'പരിചയം',
    'VACANCIES': 'ഒഴിവുകൾ',
    'DEADLINE': 'അവസാന തീയതി',
    'PUBLISHED': 'പ്രസിദ്ധീകരിച്ചത്',
    'Locations': 'സ്ഥലങ്ങൾ',
    'Primary': 'പ്രാഥമികം',
    'Job description': 'ജോലി വിവരണം',
    'Minimum education': 'കുറഞ്ഞ വിദ്യാഭ്യാസം',
    'Required skills': 'ആവശ്യമായ കഴിവുകൾ',
    'Languages': 'ഭാഷകൾ',
    'About company': 'കമ്പനിയെക്കുറിച്ച്',
    'Withdraw Application': 'അപേക്ഷ പിൻവലിക്കുക',
    'Withdraw Application?': 'അപേക്ഷ പിൻവലിക്കണോ?',
    'Application withdrawn successfully': 'അപേക്ഷ വിജയകരമായി പിൻവലിച്ചു',
    'Withdraw': 'പിൻവലിക്കുക',
    'You have no applications under this filter status.':
        'ഈ ഫിൽട്ടർ സ്റ്റാറ്റസിന് കീഴിൽ നിങ്ങൾക്ക് അപേക്ഷകളൊന്നുമില്ല.',
    'Personal Info': 'വ്യക്തിഗത വിവരങ്ങൾ',
    'Experience': 'പരിചയം',
    'Preferences': 'മുൻഗണനകൾ',
    'Step 1 of 3': 'ഘട്ടം 1/3',
    'Step 2 of 3': 'ഘട്ടം 2/3',
    'Step 3 of 3: Review & Submit Registration':
        'ഘട്ടം 3/3: അവലോകനം & രജിസ്ട്രേഷൻ സമർപ്പിക്കുക',
    'Basic Info': 'അടിസ്ഥാന വിവരങ്ങൾ',
    'Professional': 'പ്രൊഫഷണൽ',
    'Failed to save details:': 'വിവരങ്ങൾ സംരക്ഷിക്കുന്നതിൽ പരാജയപ്പെട്ടു:',
    'Valid email required': 'സാധുവായ ഇമെയിൽ ആവശ്യമാണ്',
    'Required': 'ആവശ്യമാണ്',
    'Continue to Step 2': 'ഘട്ടം 2 ലേക്ക് തുടരുക',
    'Back to Roles': 'റോളുകളിലേക്ക് മടങ്ങുക',
    'Please provide your basic details to complete your profile.':
        'നിങ്ങളുടെ പ്രൊഫൈൽ പൂർത്തിയാക്കാൻ അടിസ്ഥാന വിവരങ്ങൾ നൽകുക.',
    'Upload Photo': 'ഫോട്ടോ അപ്ലോഡ് ചെയ്യുക',
    'Change Photo': 'ഫോട്ടോ മാറ്റുക',
    'JPG, PNG max 5MB': 'JPG, PNG പരമാവധി 5MB',
    'Please choose an image under 5MB.': '5MB-ൽ താഴെയുള്ള ചിത്രം തിരഞ്ഞെടുക്കുക.',
    'Tell us about your educational background, work experience, and skills to help us match you with the best opportunities.':
        'മികച്ച അവസരങ്ങളുമായി നിങ്ങളെ പൊരുത്തപ്പെടുത്തുന്നതിന് നിങ്ങളുടെ വിദ്യാഭ്യാസ പശ്ചാത്തലം, തൊഴിൽ പരിചയം, കഴിവുകൾ എന്നിവയെക്കുറിച്ച് പറയുക.',
    'Professional Summary': 'പ്രൊഫഷണൽ സംഗ്രഹം',
    'Search & Add Skills': 'കഴിവുകൾ തിരയുക & ചേർക്കുക',
    'Add Languages': 'ഭാഷകൾ ചേർക്കുക',
    'Cities or Regions': 'നഗരങ്ങൾ അല്ലെങ്കിൽ പ്രദേശങ്ങൾ',
    'Preferred Salary Type': 'ഇഷ്ടപ്പെട്ട ശമ്പള തരം',
    'Preferred Job Categories': 'ഇഷ്ടപ്പെട്ട ജോലി വിഭാഗങ്ങൾ',
    'Resumes & Introduction Video': 'റെസ്യൂമുകളും ആമുഖ വീഡിയോയും',
    'Back to Step 1': 'ഘട്ടം 1 ലേക്ക് മടങ്ങുക',
    'Back to Step 2': 'ഘട്ടം 2 ലേക്ക് മടങ്ങുക',
    'Draft saved locally.': 'ഡ്രാഫ്റ്റ് ലോക്കലായി സംരക്ഷിച്ചു.',
    'Draft saved successfully.': 'ഡ്രാഫ്റ്റ് വിജയകരമായി സംരക്ഷിച്ചു.',
    'Save as Draft': 'ഡ്രാഫ്റ്റ് ആയി സംരക്ഷിക്കുക',
    'Preview Details': 'വിശദാംശങ്ങൾ പ്രിവ്യൂ ചെയ്യുക',
    'Date of Birth *': 'ജനന തീയതി *',
    'Current Address *': 'നിലവിലെ വിലാസം *',
    'Enter your full address (house no., street, city, PIN)':
        'നിങ്ങളുടെ മുഴുവൻ വിലാസം നൽകുക (വീട് നമ്പർ, തെരുവ്, നഗരം, പിൻ)',
    'No matching options. Type above to add your own.':
        'പൊരുത്തപ്പെടുന്ന ഓപ്ഷനുകളൊന്നുമില്ല. സ്വന്തമായി ചേർക്കാൻ മുകളിൽ ടൈപ്പ് ചെയ്യുക.',
    'Please accept the declarations and terms to proceed.':
        'തുടരാൻ പ്രഖ്യാപനങ്ങളും നിബന്ധനകളും അംഗീകരിക്കുക.',
    'Registration Submitted!': 'രജിസ്ട്രേഷൻ സമർപ്പിച്ചു!',
    'Welcome to Kervia! Your professional profile is now verified and active. Recruiters can now discover your resume and applications.':
        'കേർവിയയിലേക്ക് സ്വാഗതം! നിങ്ങളുടെ പ്രൊഫഷണൽ പ്രൊഫൈൽ ഇപ്പോൾ പരിശോധിച്ച് സജീവമാക്കിയിരിക്കുന്നു. റിക്രൂട്ടർമാർക്ക് ഇപ്പോൾ നിങ്ങളുടെ റെസ്യൂമും അപേക്ഷകളും കണ്ടെത്താനാകും.',
    'Go to Home / Dashboard': 'ഹോം / ഡാഷ്ബോർഡിലേക്ക് പോകുക',
    'Review Your Registration Details': 'നിങ്ങളുടെ രജിസ്ട്രേഷൻ വിശദാംശങ്ങൾ അവലോകനം ചെയ്യുക',
    'Please verify all your personal, professional, and preference details before final submission.':
        'അന്തിമ സമർപ്പണത്തിന് മുമ്പ് നിങ്ങളുടെ എല്ലാ വ്യക്തിപരവും പ്രൊഫഷണലും മുൻഗണനാപരവുമായ വിശദാംശങ്ങൾ പരിശോധിക്കുക.',
    'Job & Location Preferences': 'ജോലി & സ്ഥല മുൻഗണനകൾ',
    'EMAIL ADDRESS': 'ഇമെയിൽ വിലാസം',
    'PHONE NUMBER': 'ഫോൺ നമ്പർ',
    'DATE OF BIRTH': 'ജനന തീയതി',
    'GENDER': 'ലിംഗഭേദം',
    'CURRENT ADDRESS': 'നിലവിലെ വിലാസം',
    'Panchayat / Muni.': 'പഞ്ചായത്ത് / മു.',
    'HIGHEST QUALIFICATION': 'ഏറ്റവും ഉയർന്ന യോഗ്യത',
    'CURRENT OCCUPATION': 'നിലവിലെ തൊഴിൽ',
    'YEARS OF EXPERIENCE': 'വർഷങ്ങളുടെ പരിചയം',
    'COMPENSATION OVERVIEW': 'നഷ്ടപരിഹാര അവലോകനം',
    'VALIDATED KEY SKILLS': 'സാധൂകരിച്ച പ്രധാന കഴിവുകൾ',
    'LANGUAGES KNOWN': 'അറിയാവുന്ന ഭാഷകൾ',
    'TARGET LOCATIONS': 'ലക്ഷ്യ സ്ഥലങ്ങൾ',
    'SALARY EXPECTATION TYPE': 'ശമ്പള പ്രതീക്ഷ തരം',
    'PREFERRED ROLES': 'ഇഷ്ടപ്പെട്ട റോളുകൾ',
    'Applicant Declaration & Consent': 'അപേക്ഷകന്റെ പ്രഖ്യാപനവും സമ്മതവും',
    'I hereby confirm that all details provided above are true, accurate, and complete to the best of my knowledge. I understand that any false information may lead to the cancellation of my candidature.':
        'മുകളിൽ നൽകിയ എല്ലാ വിവരങ്ങളും എന്റെ അറിവിൽ പരമാവധി ശരിയും കൃത്യവും പൂർണ്ണവുമാണെന്ന് ഞാൻ സ്ഥിരീകരിക്കുന്നു. തെറ്റായ വിവരങ്ങൾ എന്റെ സ്ഥാനാർത്ഥിത്വം റദ്ദാക്കുന്നതിന് ഇടയാക്കുമെന്ന് ഞാൻ മനസ്സിലാക്കുന്നു.',
    "I agree to Kervia's Terms of Service and acknowledge the Privacy Policy regarding the handling and storage of my professional data.":
        'എന്റെ പ്രൊഫഷണൽ ഡാറ്റയുടെ കൈകാര്യം ചെയ്യലും സംഭരണവും സംബന്ധിച്ച പ്രൈവസി പോളിസി അംഗീകരിക്കുന്നു, കേർവിയയുടെ സേവന നിബന്ധനകൾ ഞാൻ അംഗീകരിക്കുന്നു.',
    'Submission failed:': 'സമർപ്പണം പരാജയപ്പെട്ടു:',
    'Confirm & Submit Registration': 'രജിസ്ട്രേഷൻ സ്ഥിരീകരിച്ച് സമർപ്പിക്കുക',
    '© 2026 Kervia Careers • All rights reserved. Secure encrypted transmission.':
        '© 2026 കേർവിയ കരിയേഴ്സ് • എല്ലാ അവകാശങ്ങളും നിക്ഷിപ്തം. സുരക്ഷിത എൻക്രിപ്റ്റ് ചെയ്ത ട്രാൻസ്മിഷൻ.',
    'No resume yet. Add it in Step 2.': 'ഇതുവരെ റെസ്യൂം ഇല്ല. ഘട്ടം 2-ൽ ചേർക്കുക.',
    'No intro video yet. Add it in Step 2.': 'ഇതുവരെ ആമുഖ വീഡിയോ ഇല്ല. ഘട്ടം 2-ൽ ചേർക്കുക.',
    'Kervia is committed to protecting your privacy.\n\nWe collect only the information necessary to connect job seekers with employers in your local area.\n\nYour personal data - including your name, contact details, resume, and profile information - is stored securely and shared only with employers you choose to apply to.\n\nWe do not sell your data to third parties.\n\nLocation data is used solely to match you with nearby job opportunities.\n\nFor questions about our privacy practices, contact us at privacy@kervia.in.':
        'നിങ്ങളുടെ സ്വകാര്യത സംരക്ഷിക്കാൻ കേർവിയ പ്രതിജ്ഞാബദ്ധമാണ്.\n\nനിങ്ങളുടെ പ്രാദേശിക പ്രദേശത്ത് ജോലിക്കാരെയും തൊഴിൽദാതാക്കളെയും ബന്ധിപ്പിക്കുന്നതിന് ആവശ്യമായ വിവരങ്ങൾ മാത്രമേ ഞങ്ങൾ ശേഖരിക്കുന്നുള്ളൂ.\n\nനിങ്ങളുടെ വ്യക്തിഗത ഡാറ്റ - നിങ്ങളുടെ പേര്, ബന്ധപ്പെടാനുള്ള വിശദാംശങ്ങൾ, റെസ്യൂം, പ്രൊഫൈൽ വിവരങ്ങൾ എന്നിവ ഉൾപ്പെടെ - സുരക്ഷിതമായി സംഭരിക്കുകയും നിങ്ങൾ അപേക്ഷിക്കാൻ തിരഞ്ഞെടുക്കുന്ന തൊഴിൽദാതാക്കളുമായി മാത്രം പങ്കിടുകയും ചെയ്യുന്നു.\n\nഞങ്ങൾ നിങ്ങളുടെ ഡാറ്റ മൂന്നാം കക്ഷികൾക്ക് വിൽക്കുന്നില്ല.\n\nനിങ്ങളുടെ സമീപത്തുള്ള ജോലി അവസരങ്ങളുമായി പൊരുത്തപ്പെടുത്തുന്നതിന് മാത്രമാണ് ലൊക്കേഷൻ ഡാറ്റ ഉപയോഗിക്കുന്നത്.\n\nഞങ്ങളുടെ സ്വകാര്യതാ രീതികളെക്കുറിച്ചുള്ള ചോദ്യങ്ങൾക്ക്, privacy@kervia.in എന്ന വിലാസത്തിൽ ബന്ധപ്പെടുക.',
    'By using Kervia, you agree to the following terms:\n1. You must provide accurate information in your profile and job listings.\n2. Employers must have valid business credentials to post jobs.\n3. Job seekers must not misrepresent their qualifications.\n4. Kervia reserves the right to suspend accounts that violate community guidelines.\n5. All interview scheduling and payment features are subject to applicable service fees.\n6. Content you upload (resumes, videos, company logos) must not contain inappropriate material.\nFor the full terms of service, visit kervia.in/ terms.':
        'കേർവിയ ഉപയോഗിക്കുന്നതിലൂടെ, നിങ്ങൾ ഇനിപ്പറയുന്ന നിബന്ധനകൾ അംഗീകരിക്കുന്നു:\n1. നിങ്ങളുടെ പ്രൊഫൈലിലും ജോലി ലിസ്റ്റിംഗുകളിലും കൃത്യമായ വിവരങ്ങൾ നൽകണം.\n2. ജോലി പോസ്റ്റ് ചെയ്യുന്നതിന് തൊഴിൽദാതാക്കൾക്ക് സാധുവായ ബിസിനസ് ക്രെഡൻഷ്യലുകൾ ഉണ്ടായിരിക്കണം.\n3. ജോലി അന്വേഷകർ അവരുടെ യോഗ്യതകൾ തെറ്റായി അവതരിപ്പിക്കരുത്.\n4. കമ്മ്യൂണിറ്റി മാർഗ്ഗനിർദ്ദേശങ്ങൾ ലംഘിക്കുന്ന അക്കൗണ്ടുകൾ സസ്പെൻഡ് ചെയ്യാനുള്ള അവകാശം കേർവിയയ്ക്കുണ്ട്.\n5. എല്ലാ ഇന്റർവ്യൂ ഷെഡ്യൂളിംഗും പേയ്മെന്റ് സവിശേഷതകളും ബാധകമായ സേവന ഫീസുകൾക്ക് വിധേയമാണ്.\n6. നിങ്ങൾ അപ്ലോഡ് ചെയ്യുന്ന ഉള്ളടക്കം (റെസ്യൂമുകൾ, വീഡിയോകൾ, കമ്പനി ലോഗോകൾ) അനുചിതമായ മെറ്റീരിയൽ ഉൾക്കൊള്ളരുത്.\nപൂർണ്ണമായ സേവന നിബന്ധനകൾക്കായി, kervia.in/ terms സന്ദർശിക്കുക.',
    'Kervia is a local job matching platform built to connect job seekers and employers in Kerala.\n\nOur mission is to make local employment accessible to everyone - from skilled tradespeople to office professionals - by bridging the gap between talent and opportunity in your community.\n\nKervia provides verified employer profiles, protected resumes, video introductions, and a streamlined interview scheduling system to make hiring faster and more personal.\n\nBuilt with care in Kerala':
        'കേർവിയ എന്നത് കേരളത്തിലെ ജോലിക്കാർക്കും തൊഴിൽദാതാക്കൾക്കും തമ്മിൽ ബന്ധം സ്ഥാപിക്കുന്നതിനായി നിർമ്മിച്ച പ്രാദേശിക ജോലി മാച്ചിംഗ് പ്ലാറ്റ്ഫോമാണ്.\n\nസമർത്ഥരായ കരകൗശല വിദഗ്ധർ മുതൽ ഓഫീസ് പ്രൊഫഷണലുകൾ വരെ എല്ലാവർക്കും പ്രാദേശിക തൊഴിൽ ലഭ്യമാക്കുക എന്നതാണ് ഞങ്ങളുടെ ദൗത്യം - നിങ്ങളുടെ കമ്മ്യൂണിറ്റിയിൽ കഴിവും അവസരവും തമ്മിലുള്ള വിടവ് നികത്തിക്കൊണ്ട്.\n\nവേഗത്തിലും കൂടുതൽ വ്യക്തിപരമായും നിയമനം നടത്തുന്നതിന് കേർവിയ പരിശോധിച്ച തൊഴിൽദാതാവ് പ്രൊഫൈലുകൾ, സംരക്ഷിത റെസ്യൂമുകൾ, വീഡിയോ ആമുഖങ്ങൾ, കാര്യക്ഷമമായ ഇന്റർവ്യൂ ഷെഡ്യൂളിംഗ് സംവിധാനം എന്നിവ നൽകുന്നു.\n\nകേരളത്തിൽ സ്നേഹത്തോടെ നിർമ്മിച്ചത്',
    // Company Profile
    'Company Profile Setup': 'കമ്പനി പ്രൊഫൈൽ സജ്ജീകരണം',
    'Tell us about your company to get started.':
        'ആരംഭിക്കാൻ നിങ്ങളുടെ കമ്പനിയെക്കുറിച്ച് ഞങ്ങളോട് പറയുക.',
    'Submit Profile': 'പ്രൊഫൈൽ സമർപ്പിക്കുക',
    'Profile submitted successfully!': 'പ്രൊഫൈൽ വിജയകരമായി സമർപ്പിച്ചു!',
    'Basic Information': 'അടിസ്ഥാന വിവരങ്ങൾ',
    'Company Name': 'കമ്പനിയുടെ പേര്',
    'Company name is required': 'കമ്പനിയുടെ പേര് ആവശ്യമാണ്',
    'Industry / Category': 'വ്യവസായം / വിഭാഗം',
    'Industry is required': 'വ്യവസായം ആവശ്യമാണ്',
    'Website (optional)': 'വെബ്സൈറ്റ് (ഓപ്ഷണൽ)',
    'Website': 'വെബ്സൈറ്റ്',
    'Contact Details': 'ബന്ധപ്പെടാനുള്ള വിവരങ്ങൾ',
    'Contact Email': 'കോൺടാക്റ്റ് ഇമെയിൽ',
    'Email is required': 'ഇമെയിൽ ആവശ്യമാണ്',
    'Phone is required': 'ഫോൺ ആവശ്യമാണ്',
    'Location / Address': 'സ്ഥലം / വിലാസം',
    'Location is required': 'സ്ഥലം ആവശ്യമാണ്',
    'District is required': 'ജില്ല ആവശ്യമാണ്',
    'State is required': 'സംസ്ഥാനം ആവശ്യമാണ്',
    'Company Details': 'കമ്പനി വിശദാംശങ്ങൾ',
    'Employee Size': 'ജീവനക്കാരുടെ എണ്ണം',
    'Employee size is required': 'ജീവനക്കാരുടെ എണ്ണം ആവശ്യമാണ്',
    'Founded Year': 'സ്ഥാപിത വർഷം',
    'About Your Company': 'നിങ്ങളുടെ കമ്പനിയെക്കുറിച്ച്',
    'About is required': 'ഇതിനെക്കുറിച്ചുള്ള വിവരം ആവശ്യമാണ്',
    'Company Profile': 'കമ്പനി പ്രൊഫൈൽ',
    'Your Company': 'നിങ്ങളുടെ കമ്പനി',
    'Edit Profile': 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക',
    'Edit Company Profile': 'കമ്പനി പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക',
    'Profile saved successfully.': 'പ്രൊഫൈൽ വിജയകരമായി സംരക്ഷിച്ചു.',
    // Company Jobs & Dashboard
    'Company Dashboard': 'കമ്പനി ഡാഷ്ബോർഡ്',
    'Manage your jobs and applicants from one place.':
        'നിങ്ങളുടെ ജോലികളും അപേക്ഷകരും ഒരിടത്ത് നിന്ന് നിയന്ത്രിക്കുക.',
    'Total Jobs': 'ആകെ ജോലികൾ',
    'Published': 'പ്രസിദ്ധീകരിച്ചത്',
    'Applicants': 'അപേക്ഷകർ',
    'Jobs': 'ജോലികൾ',
    'Post a Job': 'ജോലി പോസ്റ്റ് ചെയ്യുക',
    'Recent Applications': 'ഏറ്റവും പുതിയ അപേക്ഷകൾ',
    'No applications yet. Share your job links to start receiving applications.':
        'ഇതുവരെ അപേക്ഷകൾ ഇല്ല. അപേക്ഷകൾ ലഭിക്കാൻ തുടങ്ങാൻ നിങ്ങളുടെ ജോലി ലിങ്കുകൾ പങ്കിടുക.',
    'Your Jobs': 'നിങ്ങളുടെ ജോലികൾ',
    'No jobs posted yet.': 'ഇതുവരെ ജോലി പോസ്റ്റ് ചെയ്തിട്ടില്ല.',
    'Post your first job to start receiving applications.':
        'അപേക്ഷകൾ സ്വീകരിക്കാൻ നിങ്ങളുടെ ആദ്യ ജോലി പോസ്റ്റ് ചെയ്യുക.',
    'Closed': 'അടച്ചത്',
    'Close Job': 'ജോലി അടയ്ക്കുക',
    'Reopen Job': 'ജോലി വീണ്ടും തുറക്കുക',
    'Delete': 'ഇല്ലാതാക്കുക',
    'Delete this job?': 'ഈ ജോലി ഇല്ലാതാക്കണോ?',
    'This will permanently remove the job posting. This action cannot be undone.':
        'ഇത് ജോലി പോസ്റ്റിംഗ് സ്ഥിരമായി നീക്കം ചെയ്യും. ഈ പ്രവർത്തനം തിരിച്ചെടുക്കാനാവില്ല.',
    'Edit Job': 'ജോലി എഡിറ്റ് ചെയ്യുക',
    'Job Title': 'ജോലി തലക്കെട്ട്',
    'Job title is required': 'ജോലി തലക്കെട്ട് ആവശ്യമാണ്',
    'Occupation / Category': 'തൊഴിൽ / വിഭാഗം',
    'Occupation is required': 'തൊഴിൽ ആവശ്യമാണ്',
    'Salary Amount': 'ശമ്പള തുക',
    'Salary Type': 'ശമ്പള തരം',
    'Experience Required': 'ആവശ്യമായ പരിചയം',
    'Application Deadline': 'അപേക്ഷാ സമയപരിധി',
    'Minimum Education': 'കുറഞ്ഞ വിദ്യാഭ്യാസം',
    'Required Skills (comma separated)': 'ആവശ്യമായ കഴിവുകൾ (കോമ കൊണ്ട് വേർതിരിച്ചത്)',
    'Job Description': 'ജോലി വിവരണം',
    'Description is required': 'വിവരണം ആവശ്യമാണ്',
    'About Company': 'കമ്പനിയെ കുറിച്ച്',
    'Publish Job': 'ജോലി പ്രസിദ്ധീകരിക്കുക',
    'Job posted successfully!': 'ജോലി വിജയകരമായി പോസ്റ്റ് ചെയ്തു!',
    'Job updated successfully.': 'ജോലി വിജയകരമായി അപ്ഡേറ്റ് ചെയ്തു.',
    'Employment Type': 'തൊഴിൽ തരം',
    'Work Mode': 'ജോലി രീതി',
    'Received Applications': 'ലഭിച്ച അപേക്ഷകൾ',
    'No applications received yet.': 'ഇതുവരെ അപേക്ഷകൾ ലഭിച്ചിട്ടില്ല.',
    'Applications from candidates will appear here.':
        'സ്ഥാനാർത്ഥികളിൽ നിന്നുള്ള അപേക്ഷകൾ ഇവിടെ ദൃശ്യമാകും.',
    'Update Status': 'സ്ഥിതി അപ്ഡേറ്റ് ചെയ്യുക',
    'Update Application Status': 'അപേക്ഷാ സ്ഥിതി അപ്ഡേറ്റ് ചെയ്യുക',
    'Candidate': 'സ്ഥാനാർത്ഥി',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ml';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppL10nContextExtension on BuildContext {
  /// Registers dependencies on both theme and language so the page
  /// rebuilds when either changes.
  void adaptive() {
    Theme.of(this);
    AppLocalizations.of(this);
  }

  String tr(String key) => AppLocalizations.of(this).tr(key);
}

const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];