import 'package:flutter/cupertino.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Privacy Policy",
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
                  "Privacy Policy",
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
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Welcome to AgriTek: A Mobile App for Effective Farming and Agricultural Practices. Please read this Privacy Policy carefully before using the AgriTek mobile application (\"App\") operated by the AgriTek Development Team (\"we\", \"our\", or \"us\").",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "1. Data Collection",
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
                  "AgriTek collects data to provide better services to its users. This includes information you provide directly, such as your name, email address, and location, as well as data collected automatically, such as app usage statistics and device information.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "2. Use of Data",
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
                  "The data collected is used to improve the functionality of the App, provide personalized recommendations, and ensure a seamless user experience. We do not sell or share your personal data with third parties without your consent.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "3. Data Security",
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
                  "We take appropriate security measures to protect your data from unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "4. User Rights",
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
                  "You have the right to access, update, or delete your personal data stored in the App. If you wish to exercise these rights, please contact us using the details provided below.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "5. Updates to Privacy Policy",
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
                  "We reserve the right to update this Privacy Policy at any time. Changes will be effective immediately upon posting. Continued use of the App after changes are made signifies your acceptance of the updated Privacy Policy.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "6. Contact Us",
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
                  "If you have questions, concerns, or feedback regarding this Privacy Policy, please contact us:\n\n"
                  "Email: davevilla58@gmail.com\n"
                  "Address: AgriTek Team\n"
                  "Filamer Christian University Inc.\n"
                  "HQG2+6P4, Roxas Avenue, Roxas City, Capiz, 5800",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
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
