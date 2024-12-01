import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditDriverFormMobile extends StatefulWidget {
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

  EditDriverFormMobile({
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
  _EditDriverFormMobileState createState() => _EditDriverFormMobileState();
}

class _EditDriverFormMobileState extends State<EditDriverFormMobile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _bodyNumberController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late String _selectedTag;
  late String _driverPhotoUrl;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _selectedCodingScheme;

  final List<String> codingSchemes = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

@override
void initState() {
  super.initState();
  _firstNameController = TextEditingController(text: widget.firstName);
  _lastNameController = TextEditingController(text: widget.lastName);
  _idNumberController = TextEditingController(text: widget.idNumber);
  _bodyNumberController = TextEditingController(text: widget.bodyNumber);
  _addressController = TextEditingController(text: widget.address);
  _phoneNumberController = TextEditingController(text: widget.phoneNumber);

  // Ensure that the tag is valid, fallback to 'Member' if invalid
  _selectedTag = ['Member', 'Operator'].contains(widget.tag) ? widget.tag : 'Member';

  _driverPhotoUrl = widget.driverPhoto.isEmpty
      ? 'images/default_avatar.png'
      : widget.driverPhoto;

  _selectedCodingScheme = widget.codingScheme;
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

        final driverRef = FirebaseDatabase.instance.ref('driversAccount/$driverKey');
        await driverRef.update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'bodyNumber': _bodyNumberController.text,
          'address': _addressController.text,
          'phoneNumber': _phoneNumberController.text,
          'tag': _selectedTag,
          'driverPhoto': _driverPhotoUrl,
          'codingScheme': _selectedCodingScheme,
        });

        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        
       
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error updating driver: $e');
      
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {int? maxLength, bool isEditable = true}) {
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

  Widget _buildDropdown(String labelText, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: _isEditing ? onChanged : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_driverPhotoUrl),
                  radius: 50,
                ),
              ),
              const SizedBox(height: 20.0),
              _buildTextField(_firstNameController, 'First Name'),
              const SizedBox(height: 10.0),
              _buildTextField(_lastNameController, 'Last Name'),
              const SizedBox(height: 10.0),
              _buildTextField(_idNumberController, 'ID Number', maxLength: 4),
              const SizedBox(height: 10.0),
              _buildTextField(_bodyNumberController, 'Body Number', maxLength: 4),
              const SizedBox(height: 10.0),
              _buildTextField(_addressController, 'Address'),
              const SizedBox(height: 10.0),
              _buildTextField(_phoneNumberController, 'Mobile Number', maxLength: 11),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: TextEditingController(text: widget.birthdate),
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
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
              _buildDropdown('Coding Scheme', _selectedCodingScheme, codingSchemes, (value) {
                setState(() {
                  _selectedCodingScheme = value!;
                });
              }),
              const SizedBox(height: 10.0),
              _buildDropdown('Tag', _selectedTag, ['Member', 'Operator'], (value) {
                setState(() {
                  _selectedTag = value!;
                });
              }),
              const SizedBox(height: 20.0),
              if (_isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: CustomButtonStyles.elevatedButtonStyle,
                      onPressed: () => setState(() => _isEditing = false),
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
                      child: const Text('Save'),
                    ),
                  ],
                )
              else
                Center(
                  child: ElevatedButton(
                    style: CustomButtonStyles.elevatedButtonStyle,
                    onPressed: () => setState(() => _isEditing = true),
                    child: const Text('Edit Information'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
