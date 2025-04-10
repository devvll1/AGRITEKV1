import 'package:flutter/cupertino.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Terms and Conditions",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
          child: const Icon(CupertinoIcons.back,
              color: CupertinoColors.activeGreen),
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Terms and Conditions",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Effective Date: April 2025",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Welcome to AgriTek: A Mobile App for Effective Farming and Agricultural Practices. Please read these Terms and Conditions (\"Terms\") carefully before using the AgriTek mobile application (\"App\") operated by the AgriTek Development Team (\"we\", \"our\", or \"us\").",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "1. Use of the Application",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "AgriTek is a mobile application designed to provide educational content, real-time agricultural data, and community-based support to farmers and agricultural workers. The App includes features such as weather forecasts, planting guides, market price updates, and forums to assist users in making informed and sustainable agricultural decisions.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "2. Sources of Information and Third-Party Content",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "A portion of the content within AgriTek is sourced from third-party entities, including but not limited to:\n\n"
                  "- The Department of Provincial Agriculturist\n"
                  "- Roxas City Agriculture Office\n"
                  "- Publicly accessible online resources\n\n"
                  "We do not claim ownership of this third-party data. The information is presented solely for educational and reference purposes. All rights and credits remain with their original owners. If you are a rights holder and believe your content has been used without proper acknowledgment, please contact us for immediate review and action.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "3. Accuracy of Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "While we aim to provide accurate and timely information, AgriTek does not guarantee the completeness, reliability, or accuracy of any content within the App. Users are encouraged to consult with local agricultural experts or official government sources when making critical farming decisions.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "4. User Conduct",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Users are expected to use the App responsibly and respectfully. When engaging with community forums or submitting content, you agree to refrain from:\n\n"
                  "- Sharing false, misleading, or harmful information\n"
                  "- Posting offensive, discriminatory, or abusive content\n"
                  "- Uploading copyrighted or confidential material without authorization\n"
                  "- Spamming or promoting unrelated commercial content\n\n"
                  "Violation of these guidelines may result in the suspension or termination of access to the App.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "5. Intellectual Property",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "All original content, including the App’s design, layout, and features, are the intellectual property of the AgriTek Development Team unless otherwise stated. Unauthorized use, reproduction, or distribution of any part of the App is strictly prohibited.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "6. Limitation of Liability",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "The App is provided on an “as-is” and “as-available” basis. We are not liable for any direct or indirect loss, damage, or inconvenience resulting from the use or inability to use the App or reliance on any information it provides.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "7. Updates and Modifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "We reserve the right to update, modify, or discontinue any part of the App or these Terms at any time without prior notice. Continued use of the App after changes are made signifies your acceptance of the updated Terms.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "8. Contact Us",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "If you have questions, concerns, or feedback regarding these Terms and Conditions, please contact us:\n\n"
                  "Email: davevilla58@gmail.com\n"
                  "Address: AgriTek Team\n"
                  "Filamer Christian University Inc.\n"
                  "HQG2+6P4, Roxas Avenue, Roxas City, Capiz, 5800",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
