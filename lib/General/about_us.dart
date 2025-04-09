import 'package:flutter/cupertino.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "About Us",
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
                  "About Agritek",
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
                  "AgriTek is your trusted farming companion, providing tools and resources to help farmers make informed decisions. From weather updates to market prices, we aim to empower the agricultural community.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Our Mission",
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
                  "To revolutionize agriculture through technology, making farming more efficient, sustainable, and profitable for everyone.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Agritek: A Mobile App for Effective Farming and Agricultural Practices",
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
                  "Agritek is a comprehensive digital solution designed to support and modernize agriculture for farmers, agricultural workers, and emerging growers. Built with the goal of enhancing productivity and promoting sustainable farming, Agritek combines research-based agricultural knowledge with accessible mobile technology.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Leveraging the capabilities of Android smartphones, Agritek provides users with essential tools for farm management, crop monitoring, weather forecasting, and access to agricultural resources — all within a user-friendly interface. The app is designed to simplify complex farming practices, enabling users to make data-informed decisions that improve both yield and efficiency.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Features",
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
                  "- Step-by-step instructional guides for crop production\n"
                  "- Real-time weather updates\n"
                  "- Market price monitoring\n"
                  "- Community forums for farmer-to-farmer engagement and knowledge sharing\n"
                  "- Access to government-based agricultural data and insights",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Localized Approach",
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
                  "The application is grounded in local agricultural research, specifically data collected from the Department of Agriculture within Roxas City, ensuring its relevance to regional farming practices. This localized approach allows Agritek to address the unique challenges faced by the farming communities in the area.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Our Vision",
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
                  "Our vision is to bridge the gap between traditional farming and modern technology by providing an intuitive platform that empowers users to optimize their agricultural activities and embrace a more innovative, sustainable future in farming.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Agritek is not just an app — it is a reliable partner in cultivating growth, knowledge, and success in agriculture.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Contact Us",
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
                  "Email: davevilla58@gmail.com\n"
                  "Address: Agritek Team\n"
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
