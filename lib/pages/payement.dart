import 'package:flutter/material.dart';

class Payements extends StatefulWidget {
  const Payements({super.key});

  @override
  State<Payements> createState() => _PayementsState();
}

class _PayementsState extends State<Payements> {
  bool _showPaymentCard = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Payements',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: PayementCard(),
    );
  }
}

class PayementCard extends StatefulWidget {
  const PayementCard({super.key});

  @override
  State<PayementCard> createState() => _PayementCardState();
}

class _PayementCardState extends State<PayementCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          'Gerez bientot vos payements ici.',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
