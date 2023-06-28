import 'package:flutter/material.dart';

class PassSupportPage extends StatefulWidget {
  @override
  _PassSupportPageState createState() => _PassSupportPageState();
}

class _PassSupportPageState extends State<PassSupportPage> {
  bool _isExpanded = false;
  List<FAQ> _faqs = [
    FAQ(
      question: 'How do I book a ride?',
      answer: 'To book a ride, simply open the HeyAuto app, enter your pickup location and destination, and choose your preferred driver. Once the driver accepts the request, you can take the ride.',
    ),
    FAQ(
      question: 'What payment methods are accepted?',
      answer: 'We accept various payment methods, including cash and digital payments. You can pay the driver directly in cash or use digital wallets such as Paytm or UPI for a seamless payment experience.',
    ),
    FAQ(
      question: 'How can I rate a driver?',
      answer: 'You can rate a driver on the driver details page while selecting the driver or you can rate the driver in the Ride History section by selecting the ride and providing your rating.',
    ),
    
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
              child: Text('Submit'),
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



