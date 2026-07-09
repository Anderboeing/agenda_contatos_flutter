import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  @override
  void initState() {
    super.initState();

    Contact c = Contact();
    c.name = "Anderson";
    c.email = "anderson@gmail.com";
    c.phone = "1234445645";
    c.image = "img";

    helper.saveContact(c);

    helper.getAllContacts().then((list) {
      print("meus contatos: $list");
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
