import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  bool _isExpanded = false;
  List<FAQ> _faqs = [
    FAQ(
      question: 'How do I sign up as a driver?',
      answer: 'To sign up as a driver, simply download the HeyAuto app from the App Store or Google Play Store and follow the registration process. Once registered, you can start accepting ride requests.',
    ),
    FAQ(
      question: 'How can I track my earnings?',
      answer: 'You can easily track your earnings within the HeyAuto app. Simply navigate to the "Earnings" section, and you will find a detailed breakdown of your earnings and ride history.',
    ),
    FAQ(
      question: 'What if I have an issue with a passenger?',
      answer: 'If you encounter any issues with a passenger, please report the incident to our support team immediately. We will investigate the matter and take appropriate actions to ensure a safe and enjoyable experience for all users.',
    ),
    // Add more FAQs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: Colors.green.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'If you need any assistance or have any questions, please feel free to contact our support team. We are here to help!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24.0),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('support@heyauto.com'),
              onTap: () {
                // Handle email support
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: const Text('+1 123-456-7890'),
              onTap: () {
                // Handle phone support
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              subtitle: const Text('Available Mon-Fri, 9AM-5PM'),
              onTap: () {
                // Handle live chat support
              },
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                return ExpansionPanelList(
                  elevation: 0,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (panelIndex, isExpanded) {
                    setState(() {
                      _isExpanded = !isExpanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Text(
                            _faqs[index].question,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: ListTile(
                        title: Text(_faqs[index].answer),
                      ),
                      isExpanded: _isExpanded,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Can\'t find an answer? Ask us!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter your question here',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              // Handle submitting the question
              onFieldSubmitted: (value) {
                // Handle question submission
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle question submission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400, // Set the background color
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
}
