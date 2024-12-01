import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditDriverFormDesktop extends StatefulWidget {
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

  EditDriverFormDesktop({
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
  _EditDriverFormDesktopState createState() => _EditDriverFormDesktopState();
}

class _EditDriverFormDesktopState extends State<EditDriverFormDesktop> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _bodyNumberController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late String _selectedCodingScheme;
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

    // Ensure codingScheme is valid; default to "Monday" if invalid
    _selectedCodingScheme = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ].contains(widget.codingScheme)
        ? widget.codingScheme
        : 'Monday';

    // Ensure tag is valid; default to "Member" if invalid
    _selectedTag =
        ['Member', 'Operator'].contains(widget.tag) ? widget.tag : 'Member';

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
       
      }
    }
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
              DropdownButtonFormField<String>(
                value: _selectedCodingScheme,
                decoration: const InputDecoration(
                  labelText: 'Coding Scheme',
                  border: OutlineInputBorder(),
                ),
                items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        ))
                    .toList(),
                onChanged: _isEditing
                    ? (value) => setState(() => _selectedCodingScheme = value!)
                    : null,
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  border: OutlineInputBorder(),
                ),
                items: ['Member', 'Operator']
                    .map((tag) => DropdownMenuItem(
                          value: tag,
                          child: Text(tag),
                        ))
                    .toList(),
                onChanged: _isEditing
                    ? (value) => setState(() => _selectedTag = value!)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
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
