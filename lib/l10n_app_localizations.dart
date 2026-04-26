import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  bool get isHebrew => locale.languageCode == 'he';

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'AppLocalizations was not found in the widget tree.');
    return localizations!;
  }

  static final Map<String, Map<String, String>> _translations = {
    'he': {
      'Home': 'בית',
      'Activities': 'פעילויות',
      'Rewards': 'פרסים',
      'Challenges': 'אתגרים',
      'Profile': 'פרופיל',
      'Points': 'נקודות',
      'Security': 'אבטחה',
      'Admin Log In': 'כניסת מנהל',
      'Settings': 'הגדרות',
      'Notifications': 'התראות',
      'Push Notifications': 'התראות דחיפה',
      'Get updates on challenges': 'קבל עדכונים על אתגרים',
      'Appearance': 'מראה',
      'Dark Mode': 'מצב כהה',
      'Change app theme': 'שנה את ערכת הנושא של האפליקציה',
      'Privacy': 'פרטיות',
      'Location Services': 'שירותי מיקום',
      'Track green travels': 'מעקב אחר נסיעות ירוקות',
      'Language': 'שפה',
      'Hebrew': 'עברית',
      'English': 'English',
      'Terms of Service': 'תנאי שימוש',
      'Close': 'סגור',
      'History': 'היסטוריה',
      'All': 'הכל',
      'Manual': 'ידני',
      'Approved': 'אושר',
      'Pending': 'ממתין',
      'Rejected': 'נדחה',
      'No activities found': 'לא נמצאו פעילויות',
      'Manage, report and sync\nall your green actions': 'נהל, דווח וסנכרן\nאת כל הפעולות הירוקות שלך',
      'Report Green Activities': 'דיווח פעילויות ירוקות',
      'Add your actions manually with photo verification': 'הוסף פעולות ידנית עם אימות תמונה',
      'Green Activity History': 'היסטוריית פעילויות ירוקות',
      'See approved, pending and rejected reports': 'צפה בדיווחים מאושרים, ממתינים ונדחים',
      'Sync External Apps': 'סנכרון אפליקציות חיצוניות',
      'Prepare automatic tracking from services like STRAVA': 'הכן מעקב אוטומטי משירותים כמו STRAVA',
      'Manual Report': 'דיווח ידני',
      'Tap to take a photo': 'הקש לצילום תמונה',
      'What did you do?': 'מה ביצעת?',
      'Choose Activity': 'בחר פעילות',
      'Submit Report': 'שלח דיווח',
      'Reports that cannot be verified automatically will wait for admin review.': 'דיווחים שלא ניתן לאמת אוטומטית ימתינו לאישור מנהל.',
      'Please select an activity and take a photo first.': 'בחר פעילות וצלם תמונה לפני ההגשה.',
      'Image data is missing. Please try taking the photo again.': 'נתוני התמונה חסרים. נסה לצלם שוב.',
      'AI verification matched your report. Points were added immediately.': 'האימות האוטומטי תאם את הדיווח שלך. הנקודות נוספו מיד.',
      'Your report was submitted successfully and is waiting for admin review.': 'הדיווח נשלח בהצלחה וממתין לבדיקת מנהל.',
      'Awesome!': 'מעולה!',
      'Recycled Plastic Bottles': 'מיחזור בקבוקי פלסטיק',
      'Used Public Transport': 'שימוש בתחבורה ציבורית',
      'Used A Reusable Bottle': 'שימוש בבקבוק רב־פעמי',
      'Walked / Biked to Work': 'הליכה / רכיבה לעבודה',
      'Weekly Challenges': 'אתגרים שבועיים',
      'Complete tasks to earn big points!': 'השלם משימות כדי לצבור הרבה נקודות!',
      'No challenges available yet.': 'עדיין אין אתגרים זמינים.',
      'Go To Activities': 'עבור לדיווח',
      'Completed': 'הושלם',
      'No Plastic Week': 'שבוע בלי פלסטיק',
      'Use a reusable bottle or skip plastic bags for 7 actions.': 'השתמש בבקבוק רב־פעמי או ותר על שקיות פלסטיק במשך 7 פעולות.',
      'Public Transport Streak': 'רצף תחבורה ציבורית',
      'Choose buses or public transport 5 times this week.': 'בחר באוטובוס או בתחבורה ציבורית 5 פעמים השבוע.',
      'Recycling Sprint': 'ספרינט מיחזור',
      'Submit and complete 3 recycling actions.': 'דווח והשלם 3 פעולות מיחזור.',
      'Public Transport': 'תחבורה ציבורית',
      'Recycle Bottles': 'מיחזור בקבוקים',
      'Recycle plastic or glass bottles.': 'מחזר בקבוקי פלסטיק או זכוכית.',
      'Bike Commute': 'רכיבה לעבודה',
      'Bike to work or school.': 'רכב לעבודה או ללימודים.',
      'Reusable Bottle': 'בקבוק רב־פעמי',
      'Use a reusable bottle instead of disposable plastic.': 'השתמש בבקבוק רב־פעמי במקום פלסטיק חד־פעמי.',
      'Admin Control': 'בקרת מנהל',
      'Create New\nChallenge': 'צור\nאתגר חדש',
      'System\nStatistics': 'סטטיסטיקות\nמערכת',
      'Review\nRequests': 'בדיקת\nבקשות',
      'System Statistics': 'סטטיסטיקות מערכת',
      'Total activities': 'סך הפעילויות',
      'Active challenges': 'אתגרים פעילים',
      'Redeemed rewards': 'פרסים שמומשו',
      'Earned points': 'נקודות שנצברו',
      'Publish New Challenge': 'פרסום אתגר חדש',
      'Choose from templates': 'בחר מתבניות',
      'Challenge Name': 'שם האתגר',
      'Target': 'יעד',
      'PUBLISH NOW': 'פרסם עכשיו',
      'Please enter a challenge name.': 'הזן שם לאתגר.',
      'Challenge published successfully.': 'האתגר פורסם בהצלחה.',
      'Review Requests': 'בדיקת בקשות',
      'All caught up!': 'הכול טופל!',
      'No pending requests to review.': 'אין כרגע בקשות ממתינות לבדיקה.',
      'Reject': 'דחה',
      'Approve': 'אשר',
      'Activity rejected.': 'הפעילות נדחתה.',
      'Activity approved and points granted.': 'הפעילות אושרה והנקודות הוענקו.',
      'Use your points to get rewards and benefits': 'נצל את הנקודות שלך כדי לקבל פרסים והטבות',
      'Your Available Points:': 'הנקודות הזמינות שלך:',
      'What can you do with your points?': 'מה אפשר לעשות עם הנקודות שלך?',
      'View Available Rewards': 'צפה בפרסים זמינים',
      'See where rewards can be used': 'בדוק היכן ניתן להשתמש בפרסים',
      'Partner Businesses': 'בתי עסק שותפים',
      'Rewards you redeemed but have not used yet': 'פרסים שמימשת ועדיין לא השתמשת בהם',
      'My Active Rewards': 'הפרסים הפעילים שלי',
      'Available Rewards': 'פרסים זמינים',
      'Choose a reward and redeem your points:': 'בחר פרס וממש את הנקודות שלך:',
      'Redeem': 'מימוש',
      'Locked': 'נעול',
      'No active rewards yet. Redeem a reward first to generate a QR code.': 'עדיין אין פרסים פעילים. ממש קודם פרס כדי לייצר קוד QR.',
      'Redeemed rewards ready to use:': 'פרסים שמומשו ומוכנים לשימוש:',
      'Partners': 'שותפים',
      'Where to use your rewards:': 'היכן ניתן להשתמש בפרסים שלך:',
      'Redeem Reward': 'מימוש פרס',
      'Keep this screen open until the business scans your code. Enjoy your reward!': 'השאר את המסך פתוח עד שבית העסק יסרוק את הקוד שלך. תהנה מהפרס!',
      'Free Coffee (Reusable Cup)': 'קפה חינם (עם כוס רב־פעמית)',
      'One free regular coffee when using a reusable cup.': 'קפה רגיל אחד בחינם בשימוש בכוס רב־פעמית.',
      '10% Store Discount': '10% הנחה בחנות',
      'Single-use 10% discount on one purchase.': 'הנחה חד־פעמית של 10% על רכישה אחת.',
      'Bus Ticket Credit': 'זיכוי לכרטיס אוטובוס',
      'Transit credit voucher for one bus ride.': 'שובר זיכוי לנסיעה אחת באוטובוס.',
      'Tree Planting Donation': 'תרומת נטיעת עץ',
      'Convert your points into a sponsored tree planting.': 'המר את הנקודות שלך לנטיעת עץ ממומנת.',
      'Free Drink Upgrade': 'שדרוג שתייה חינם',
      'Upgrade one drink size for free.': 'שדרוג גודל של משקה אחד ללא עלות.',
      'Coffee rewards, reusable cup benefits': 'הטבות קפה והטבות לכוס רב־פעמית',
      'Discounts, tote bags, eco accessories': 'הנחות, תיקי בד ואביזרים אקולוגיים',
      'Fresh produce discounts': 'הנחות על תוצרת טרייה',
      'Free drink upgrades and pastry deals': 'שדרוגי שתייה חינם ומבצעים על מאפים',
      'Think Green': 'Think Green',
      'Think Green!': 'Think Green!',
      'Be the future of our WORLD!': 'היו העתיד של העולם שלנו!',
      'Forgot Password?': 'שכחת סיסמה?',
      'Admin Access': 'גישת מנהל',
      'Enter the configured admin access code.': 'הזן את קוד הגישה שהוגדר למנהל.',
      'Access code': 'קוד גישה',
      'CANCEL': 'ביטול',
      'LOGIN': 'התחבר',
      'Incorrect admin access code.': 'קוד הגישה למנהל שגוי.',
      'Sign in with an admin account to continue.': 'התחבר עם חשבון מנהל כדי להמשיך.',
      'This account does not have admin access.': 'לחשבון הזה אין גישת מנהל.',
      'Welcome Back': 'ברוך שובך',
      'Please enter your details': 'אנא הזן את פרטיך',
      'Or sign in with': 'או התחבר באמצעות',
      'Sign In': 'התחברות',
      'Create Account': 'יצירת חשבון',
      'Full Name': 'שם מלא',
      'Email': 'אימייל',
      'Email Address': 'כתובת אימייל',
      'Mobile Number': 'מספר נייד',
      'Phone Number': 'מספר טלפון',
      'Date Of Birth': 'תאריך לידה',
      'Password': 'סיסמה',
      'Confirm Password': 'אימות סיסמה',
      'Already have an account? Log In': 'יש לך כבר חשבון? התחבר',
      'Or sign up with': 'או הירשם באמצעות',
      'Sign Up': 'הרשמה',
      'Account created successfully.': 'החשבון נוצר בהצלחה.',
      'Forgot Password': 'שכחתי סיסמה',
      'Reset Password?': 'איפוס סיסמה?',
      'Enter the email linked to your Think Green account. We will verify you with a short security PIN before letting you create a new password.': 'הזן את האימייל שמחובר לחשבון Think Green שלך. נאמת אותך בעזרת קוד PIN קצר לפני יצירת סיסמה חדשה.',
      'Enter Email Address': 'הזן כתובת אימייל',
      'Next Step': 'השלב הבא',
      'Don\'t have an account? ': 'אין לך חשבון? ',
      'No account was found for that email address.': 'לא נמצא חשבון עם כתובת האימייל הזו.',
      'Security PIN': 'קוד אבטחה',
      'Enter PIN': 'הזן קוד',
      'Verify PIN': 'אמת קוד',
      'Create New Password': 'צור סיסמה חדשה',
      'Choose a strong password with at least 6 characters.': 'בחר סיסמה חזקה עם לפחות 6 תווים.',
      'New Password': 'סיסמה חדשה',
      'Change Password': 'שנה סיסמה',
      'Password Updated': 'הסיסמה עודכנה',
      'Your password was changed successfully. Please sign in with your new password.': 'הסיסמה שונתה בהצלחה. התחבר עם הסיסמה החדשה שלך.',
      'Back to Login': 'חזרה להתחברות',
      'Password reset session expired. Start again from Forgot Password.': 'סשן איפוס הסיסמה פג. התחל שוב ממסך שכחתי סיסמה.',
      'Please enter a valid email address.': 'הזן כתובת אימייל תקינה.',
      'No account was found for this email.': 'לא נמצא חשבון עם האימייל הזה.',
      'Incorrect password. Please try again.': 'הסיסמה שגויה. נסה שוב.',
      'Please enter your full name.': 'הזן את שמך המלא.',
      'Please enter a valid phone number.': 'הזן מספר טלפון תקין.',
      'Please select your date of birth.': 'בחר את תאריך הלידה שלך.',
      'Password must contain at least 6 characters.': 'הסיסמה חייבת להכיל לפחות 6 תווים.',
      'Passwords do not match.': 'הסיסמאות אינן תואמות.',
      'This email does not match any existing account.': 'האימייל הזה לא תואם לשום חשבון קיים.',
      'The security PIN is invalid.': 'קוד האבטחה אינו תקין.',
      'Edit Profile': 'עריכת פרופיל',
      'Save Changes': 'שמור שינויים',
      'Logout': 'התנתקות',
      'Help': 'עזרה',
      'Profile updated successfully.': 'הפרופיל עודכן בהצלחה.',
      'Google sign in': 'התחברות עם Google',
      'Google sign up': 'הרשמה עם Google',
      'Sign in with Google': 'התחברות עם Google',
      'This feature': 'הפיצ׳ר הזה',
      'Integration disabled for now (Coming Soon)': 'החיבור הזה כבוי כרגע (בקרוב)',
      'Sync Services': 'סנכרון שירותים',
      'Automate Your\nPoints': 'אוטומציה של\nהנקודות שלך',
      'Connect your favorite apps to track eco-actions automatically.': 'חבר את האפליקציות האהובות עליך כדי לעקוב אוטומטית אחרי פעולות ירוקות.',
      'CONNECT': 'חבר',
      'Connected': 'מחובר',
      'Not connected': 'לא מחובר',
      'Connected at': 'חובר בתאריך',
      'Last synced': 'סונכרן לאחרונה',
      'Just now': 'עכשיו',
      'SYNC NOW': 'סנכר עכשיו',
      'SYNC AGAIN': 'סנכר שוב',
      'SYNCED': 'סונכר',
      'DISCONNECT': 'נתק',
      'Synced just now': 'סונכר עכשיו',
      'STRAVA': 'STRAVA',
      'Track Runs, Walks And Bike Rides': 'מעקב אחרי ריצות, הליכות ורכיבות',
      'Your Strava activities were synced successfully.': 'פעילויות Strava שלך סונכרנו בהצלחה.',
      'PUBLIC TRANSPORT': 'תחבורה ציבורית',
      'MOOVIT': 'MOOVIT',
      'Track Your Public Transport Trips': 'מעקב אחרי נסיעות בתחבורה ציבורית',
      'Upload a Moovit screenshot, ticket, or route proof.': 'העלה צילום מסך ממוביט, כרטיס נסיעה או הוכחת מסלול.',
      'Open Manual Report and choose Used Public Transport to earn points.': 'פתח דיווח ידני ובחר השתמשתי בתחבורה ציבורית כדי לקבל נקודות.',
      'REPORT TRIP': 'דווח נסיעה',
      'Strava connected successfully.': 'חיבור Strava בוצע בהצלחה.',
      'Strava sync completed.': 'סנכרון Strava הושלם.',
      'Strava disconnected.': 'חיבור Strava נותק.',
      'Quick Actions': 'פעולות מהירות',
      'Report Green\nActivity': 'דיווח\nפעילות ירוקה',
      'Redeem\nPoints': 'מימוש\nנקודות',
      'Explore\nChallenges': 'חקור\nאתגרים',
      'Recent Activity': 'פעילות אחרונה',
      'No activities yet. Submit your first green action to start earning points.': 'עדיין אין פעילויות. שלח את הפעולה הירוקה הראשונה שלך כדי להתחיל לצבור נקודות.',
      'Your Points': 'הנקודות שלך',
      'Good Morning': 'בוקר טוב',
      'Take Photo': 'צלם תמונה',
      'Choose From Gallery': 'בחר מהגלריה',
      'Profile image updated successfully.': 'תמונת הפרופיל עודכנה בהצלחה.',
      'Not enough points to redeem this reward yet.': 'עדיין אין לך מספיק נקודות למימוש הפרס הזה.',
      'All rewards are unlocked.': 'כל הפרסים כבר זמינים עבורך.',
      'Unknown User': 'משתמש לא ידוע',
      'No pending approvals right now.': 'כרגע אין בקשות שממתינות לאישור.',
      'No partner businesses available yet.': 'עדיין אין עסקים שותפים זמינים.',
    },
  };

  String raw(String value) {
    if (!isHebrew) return value;
    return _translations['he']?[value] ?? value;
  }

  String languageLabel(Locale locale) => locale.languageCode == 'he' ? raw('Hebrew') : raw('English');

  String daysLeft(int days) => isHebrew ? 'נותרו $days ימים' : '$days days left';

  String pointsWithPlus(int points) => isHebrew ? '+$points נק׳' : '+$points';

  String pointsShort(int points) => isHebrew ? '+$points נק׳' : '+$points pts';

  String pointsLabel(int points) => isHebrew ? '$points נקודות' : '$points Points';

  String availablePointsLabel(int points) => isHebrew ? 'נקודות זמינות: $points' : 'Available points: $points';

  String nextRewardAt(int points) => isHebrew ? 'הפרס הבא ב־$points נקודות' : 'Next reward at: $points points';

  String codeLabel(String code) => isHebrew ? 'קוד: $code' : 'Code: $code';

  String showQrAt(String partnerName) => isHebrew ? 'הצג את קוד ה-QR הזה ב־$partnerName' : 'Show this QR code at $partnerName';

  String rewardsLabel(String rewards) => isHebrew ? 'הטבות: $rewards' : 'Rewards: $rewards';

  String redeemedPointsPartner(int points, String partnerName) => isHebrew ? '$points נק׳ • $partnerName' : '$points Points • $partnerName';

  String redeemedOn(String value) => isHebrew ? 'מומש $value' : 'Redeemed $value';

  String submittedOn(String value) => isHebrew ? 'נשלח: $value' : 'Submitted: $value';

  String languageUpdated(Locale locale) => isHebrew ? 'השפה עודכנה ל${languageLabel(locale)}.' : 'Language updated to ${languageLabel(locale)}.';

  String comingSoon([String? feature]) {
    final label = feature == null ? raw('This feature') : raw(feature);
    return isHebrew ? '$label יחובר בשלב הבא.' : '$label will be connected in the next phase.';
  }

  String analysisFailed(Object error) => isHebrew ? 'האימות נכשל. הדיווח לא נשלח. שגיאה: $error' : 'Analysis failed. The report was not submitted. Error: $error';


  String securityPinSentTo(String email) => isHebrew ? 'הזן את קוד האימות שנשלח ל־$email.' : 'Enter the verification PIN sent to $email.';

  String welcomeBackUser(String name) => isHebrew ? 'היי, ברוך שובך – $name' : 'Hi, Welcome Back – $name';

  String welcomeBackFirstName(String firstName) => isHebrew ? 'ברוך שובך $firstName!' : 'Welcome back $firstName!';

  String challengeRewardUnlocked(int points) => isHebrew ? 'השלמת את האתגר וקיבלת $points נקודות בונוס.' : 'You completed the challenge and earned $points bonus points.';

  String challengeProgress(int current, int target) => '$current/$target';

  String challengeButtonLabel(bool isCompleted) => isCompleted ? raw('Completed') : raw('Go To Activities');

  String sourceFilterLabel(String rawFilter) => raw(rawFilter);

  String statusLabel(String rawStatus) => raw(rawStatus);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'he'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension AppLocalizationContextX on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  String tr(String value) => loc.raw(value);
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
