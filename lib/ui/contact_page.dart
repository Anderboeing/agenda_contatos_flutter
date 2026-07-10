import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({this.contact, super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  late Contact _editedContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloqueia o pop automático para você validar no callback
      onPopInvokedWithResult: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            _editedContact.name != "" ? _editedContact.name : "Novo Contato",
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.image != ""
                          ? FileImage(File(_editedContact.image))
                          : AssetImage("images/person.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () {
                  ImagePicker().pickImage(source: ImageSource.gallery).then((
                    file,
                  ) {
                    if (file == null) return;
                    setState(() {
                      _editedContact.image = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPop(bool didPop, dynamic result) async {
    // Se o Flutter já executou o pop automaticamente, não faz nada
    if (didPop) return;

    if (_userEdited) {
      // Exiba seu diálogo de confirmação aqui
      bool showDialogResult =
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Descartar Alterações?"),
                content: const Text("Se sair, as alterações serão perdidas."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false), // Não sai
                    child: const Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, true), // Confirma a saída
                    child: const Text("Sim"),
                  ),
                ],
              );
            },
          ) ??
          false;

      // Se o usuário confirmou, fecha a tela manualmente
      if (showDialogResult && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      // Se o usuário não editou nada, fecha a tela direto
      Navigator.of(context).pop();
    }
  }
}
