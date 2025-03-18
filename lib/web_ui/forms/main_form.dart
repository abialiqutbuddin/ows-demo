import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ows/controller/state_management/state_manager.dart';
import 'package:ows/mobile_ui/forms/documents_upload.dart';
import 'package:ows/web_ui/forms/financials.dart';
import 'package:ows/web_ui/forms/personal_info_screen.dart';
import 'package:ows/web_ui/forms/student_education.dart';

import '../../controller/forms/form_screen_controller.dart';
import 'documents_upload.dart';

class IndexStackScreen extends StatefulWidget {
  @override
  _IndexStackScreenState createState() => _IndexStackScreenState();
}

class _IndexStackScreenState extends State<IndexStackScreen> {
  int selectedIndex = 0;

  final FormController controller = Get.find<FormController>();
  final GlobalStateController gController = Get.find<GlobalStateController>();


// List of placeholder pages. Replace these with your actual widgets.
  late final List<Map<String, dynamic>> pages;

// Get the title dynamically
  String getPageTitle(int index) {
    return pages[index].keys.first; // Retrieves the first (and only) key of the selected page
  }

  void loadDefaultValues(){
    controller.dateOfBirth.value = gController.user.value.dob!;
    controller.fullName.value = gController.user.value.fullName!;
    controller.mobileNo.value = gController.user.value.mobileNo!;
    controller.whatsappNo.value = gController.user.value.whatsappNo!;
    controller.email.value = gController.user.value.email!;
    controller.residentialAddress.value = gController.user.value.address!;
    controller.fatherName.value = gController.user.value.fatherName!;
    controller.motherName.value = gController.user.value.motherName !;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //loadDefaultValues();
    pages = [
      {'Personal Information': {
        'page':FormScreenW(),
        'icon': Obx(() => controller.checkPersonalInfo() ? Icon( Icons.check_circle_rounded, color: Colors.green,) : Icon(Icons.error_rounded))}},
      {'Financial Information': {'page':FinancialFormScreenW(),
        'icon': Obx(() => controller.checkFinancialInfo() ? Icon( Icons.check_circle_rounded, color: Colors.green,) : Icon(Icons.error_rounded))}},
      {'Financial Information Extended': {'page':StudentEducationW(),
        'icon':Obx(() => controller.checkFinancialExtended() ? Icon( Icons.check_circle_rounded, color: Colors.green,) : Icon(Icons.error_rounded))}},
      {'Documents Upload':{'page': DocumentsFormScreenW(),
        'icon':Obx(() => controller.isDependentsComplete.value ? Icon( Icons.check_circle_rounded, color: Colors.green,) : Icon(Icons.error_rounded))}},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffcf6),
      appBar: AppBar(
        title: Text(getPageTitle(selectedIndex)), // Display the title dynamically
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(14),
            width: 300,
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color(0xffffead1),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: pages[index].values.first['icon'], // Display icon
                  title: Text(getPageTitle(index),style: TextStyle(fontWeight: FontWeight.bold),), // Show correct title in sidebar
                  selected: index == selectedIndex,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          // Right Column: Animated page transition
          Expanded(
            child: Container(
              color: Colors.white,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset(0.0, 0.0),
                  ).animate(animation);
                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                // Use a unique key for the widget to trigger animation
                child: pages[selectedIndex].values.first['page'],
              ),
            ),
          ),
          SizedBox(width: 150,)
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Provide a unique key for AnimatedSwitcher to detect changes
      key: ValueKey(title),
      alignment: Alignment.center,
      color: Colors.blue[100],
      child: Text(
        title,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}