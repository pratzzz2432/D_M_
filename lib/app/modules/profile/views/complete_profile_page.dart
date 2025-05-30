import 'package:d_m/app/common/widgets/translatable_text.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final Color accentColor = const Color(0xFF5F6898);
  final Color backgroundColor = const Color(0xFFE3F2FD);

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyContactController =
  TextEditingController();
  final TextEditingController abhaIdController = TextEditingController();
  final TextEditingController otherMedicalHistoryController =
  TextEditingController();
  final TextEditingController otherAllergiesController =
  TextEditingController();
  final TextEditingController otherMedicationsController =
  TextEditingController();
  final TextEditingController otherDisabilitiesController =
  TextEditingController();

  String? selectedBloodGroup;
  String? selectedEmergencyRelation;

  // Dropdown options
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> emergencyRelations = [
    'Father',
    'Mother',
    'Sibling',
    'Spouse',
    'Friend',
    'Other',
  ];

  // Multi-select options
  final List<String> medicalHistoryOptions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'Epilepsy',
    'Cancer',
    'Thyroid Disorder',
    'Kidney Disease',
    'Liver Disease',
    'None',
    'Other',
  ];
  final List<String> allergiesOptions = [
    'Peanuts',
    'Shellfish',
    'Pollen',
    'Dust',
    'Dairy',
    'Gluten',
    'Insect Stings',
    'Latex',
    'Medication',
    'None',
    'Other',
  ];
  final List<String> medicationsOptions = [
    'Insulin',
    'Aspirin',
    'Antibiotics',
    'Steroids',
    'Painkillers',
    'Antidepressants',
    'Antihistamines',
    'Blood Pressure Medications',
    'Cholesterol Medications',
    'Thyroid Medications',
    'Vitamins',
    'Herbal Supplements',
    'None',
    'Other',
  ];
  final List<String> disabilitiesOptions = [
    'Hearing Impairment',
    'Vision Impairment',
    'Physical Disability',
    'Cognitive Disability',
    'Speech Impairment',
    'Mental Health Condition',
    'Autism Spectrum Disorder',
    'Learning Disability',
    'Chronic Illness',
    'None',
    'Other',
  ];

  // Selected values
  List<String> selectedMedicalHistory = [];
  List<String> selectedAllergies = [];
  List<String> selectedMedications = [];
  List<String> selectedDisabilities = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      ageController.text = prefs.getString('age') ?? '';
      emergencyNameController.text = prefs.getString('emergencyName') ?? '';
      emergencyContactController.text =
          prefs.getString('emergencyContact') ?? '';
      abhaIdController.text = prefs.getString('abhaId') ?? '';
      selectedBloodGroup = prefs.getString('bloodGroup');
      selectedEmergencyRelation = prefs.getString('emergencyRelation');

      selectedMedicalHistory = prefs.getStringList('medicalHistory') ?? [];
      selectedAllergies = prefs.getStringList('allergies') ?? [];
      selectedMedications = prefs.getStringList('medications') ?? [];
      selectedDisabilities = prefs.getStringList('disabilities') ?? [];
    });
  }

  Future<void> _saveProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('age', ageController.text);
    await prefs.setString('bloodGroup', selectedBloodGroup ?? '');
    await prefs.setString('emergencyName', emergencyNameController.text);
    await prefs.setString('emergencyContact', emergencyContactController.text);
    await prefs.setString('emergencyRelation', selectedEmergencyRelation ?? '');
    await prefs.setString('abhaId', abhaIdController.text);

    // Save multi-select lists
    await prefs.setStringList(
      'medicalHistory',
      _getUpdatedList(
        selectedMedicalHistory,
        otherMedicalHistoryController.text,
      ),
    );
    await prefs.setStringList(
      'allergies',
      _getUpdatedList(selectedAllergies, otherAllergiesController.text),
    );
    await prefs.setStringList(
      'medications',
      _getUpdatedList(selectedMedications, otherMedicationsController.text),
    );
    await prefs.setStringList(
      'disabilities',
      _getUpdatedList(selectedDisabilities, otherDisabilitiesController.text),
    );

    Navigator.pop(context, true); // Refresh ProfilePage
  }

  List<String> _getUpdatedList(List<String> selectedItems, String otherText) {
    List<String> updatedList = List.from(selectedItems);
    if (updatedList.contains("Other") && otherText.isNotEmpty) {
      updatedList.remove("Other");
      updatedList.add(otherText);
    }
    return updatedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: TranslatableText('Complete Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: accentColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField("Name", nameController),
            buildTextField(
              "Age",
              ageController,
              keyboardType: TextInputType.number,
            ),
            buildDropdownField("Blood Group", bloodGroups, selectedBloodGroup, (
                value,
                ) {
              setState(() => selectedBloodGroup = value);
            }),
            buildTextField("ABHA ID", abhaIdController),

            TranslatableText("Emergency Contact", style: sectionTitleStyle()),
            buildTextField("Name", emergencyNameController),
            buildDropdownField(
              "Relation",
              emergencyRelations,
              selectedEmergencyRelation,
                  (value) {
                setState(() => selectedEmergencyRelation = value);
              },
            ),
            buildTextField(
              "Phone Number",
              emergencyContactController,
              keyboardType: TextInputType.phone,
            ),

            buildMultiSelectField(
              "Medical History",
              medicalHistoryOptions,
              selectedMedicalHistory,
              otherMedicalHistoryController,
            ),
            buildMultiSelectField(
              "Allergies",
              allergiesOptions,
              selectedAllergies,
              otherAllergiesController,
            ),
            buildMultiSelectField(
              "Existing Medications",
              medicationsOptions,
              selectedMedications,
              otherMedicationsController,
            ),
            buildMultiSelectField(
              "Disabilities",
              disabilitiesOptions,
              selectedDisabilities,
              otherDisabilitiesController,
            ),

            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfileData,
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                child: TranslatableText(
                  'Save Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildDropdownField(
      String label,
      List<String> items,
      String? selectedValue,
      ValueChanged<String?> onChanged,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items:
        items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildMultiSelectField(
      String label,
      List<String> items,
      List<String> selectedValues,
      TextEditingController otherController,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiSelectDialogField(
          title: TranslatableText(label),
          buttonText: Text("Select $label"),
          items: items.map((e) => MultiSelectItem<String>(e, e)).toList(),
          initialValue: selectedValues,
          onConfirm: (values) {
            setState(() {
              selectedValues.clear();
              selectedValues.addAll(values);
            });
          },
        ),
        if (selectedValues.contains('Other'))
          buildTextField("Specify Other $label", otherController),
        SizedBox(height: 12),
      ],
    );
  }

  TextStyle sectionTitleStyle() =>
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor);
}
