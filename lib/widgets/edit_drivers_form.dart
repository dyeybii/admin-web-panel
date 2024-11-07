import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditDriverForm extends StatefulWidget {
  final String driverId;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String bodyNumber;
  final String email;
  final String birthdate;
  final String address;
  final String phoneNumber;
  final String codingScheme;
  final String tag;
  final String driverPhoto;
  

  EditDriverForm({
    required this.driverId,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.bodyNumber,
    required this.email,
    required this.birthdate,
    required this.address,
    required this.phoneNumber,
    required this.codingScheme,
    required this.tag,
    required this.driverPhoto,
    
  });

  @override
  _EditDriverFormState createState() => _EditDriverFormState();
}

class _EditDriverFormState extends State<EditDriverForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _bodyNumberController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _codingSchemeController;
  late String _selectedTag;
  late String _driverPhotoUrl;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _idNumberController = TextEditingController(text: widget.idNumber);
    _bodyNumberController = TextEditingController(text: widget.bodyNumber);
    _addressController = TextEditingController(text: widget.address);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
    _codingSchemeController = TextEditingController(text: widget.codingScheme);
    _selectedTag = widget.tag;
    _driverPhotoUrl = widget.driverPhoto.isEmpty
        ? 'images/default_avatar.png'
        : widget.driverPhoto;
   
    _fetchDriverByUID();
  }

  Future<String?> _fetchDriverByUID() async {
    final driverRef = FirebaseDatabase.instance.ref('driversAccount');
    final query = driverRef.orderByChild('uid').equalTo(widget.driverId);

    try {
      DataSnapshot snapshot = await query.get();
      if (snapshot.exists) {
        String? driverKey;
        Map data = snapshot.value as Map;
        data.forEach((key, value) {
          if (value['uid'] == widget.driverId) {
            driverKey = key;
          }
        });
        return driverKey;
      } else {
        print('No driver found with UID: ${widget.driverId}');
        return null;
      }
    } catch (e) {
      print('Error fetching driver data: $e');
      return null;
    }
  }

  Future<void> _updateDriver(String driverKey) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final driverRef =
            FirebaseDatabase.instance.ref('driversAccount/$driverKey');
        await driverRef.update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'bodyNumber': _bodyNumberController.text,
          'address': _addressController.text,
          'phoneNumber': _phoneNumberController.text,
          'tag': _selectedTag,
          'driverPhoto': _driverPhotoUrl,
          'codingScheme': _codingSchemeController.text,

        });

        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver updated successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error updating driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating driver: $e')),
        );
      }
    }
  }

  Widget buildTextField(TextEditingController controller, String labelText,
      {int? maxLength, bool isEditable = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      maxLength: maxLength,
      enabled: isEditable && _isEditing,
    );
  }

  Widget buildFormFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              buildTextField(_firstNameController, 'First Name'),
              const SizedBox(height: 10.0),
              buildTextField(_lastNameController, 'Last Name'),
              const SizedBox(height: 10.0),
              buildTextField(_idNumberController, 'ID Number', maxLength: 4),
              const SizedBox(height: 10.0),
              buildTextField(_bodyNumberController, 'Body Number',
                  maxLength: 4),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: TextEditingController(text: widget.birthdate),
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: Column(
            children: [
              buildTextField(_addressController, 'Address'),
              const SizedBox(height: 10.0),
              buildTextField(_phoneNumberController, 'Mobile Number',
                  maxLength: 11),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: TextEditingController(text: widget.email),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 10.0),
              buildTextField(_codingSchemeController, 'Coding Scheme',
                  maxLength: 4),
              const SizedBox(height: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tag',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Member'),
                          value: 'Member',
                          groupValue: _selectedTag,
                          onChanged: _isEditing
                              ? (value) =>
                                  setState(() => _selectedTag = value as String)
                              : null,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Operator'),
                          value: 'Operator',
                          groupValue: _selectedTag,
                          onChanged: _isEditing
                              ? (value) =>
                                  setState(() => _selectedTag = value as String)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(_driverPhotoUrl),
                radius: 50,
              ),
              const SizedBox(height: 10.0),
              buildFormFields(),
              const SizedBox(height: 10.0),
              _isEditing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                           style: CustomButtonStyles.elevatedButtonStyle,
                          onPressed: () {
                            setState(() => _isEditing = false);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                           style: CustomButtonStyles.elevatedButtonStyle,
                          onPressed: () async {
                            String? driverKey = await _fetchDriverByUID();
                            if (driverKey != null) {
                              _updateDriver(driverKey);
                            }
                          },
                          child: const Text('Update Driver'),
                        ),
                      ],
                    )
                  : ElevatedButton(
                     style: CustomButtonStyles.elevatedButtonStyle,
                      onPressed: () => setState(() => _isEditing = true),
                      child: const Text('Edit Information'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
