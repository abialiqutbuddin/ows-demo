import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../controller/forms/form_screen_controller.dart';

class FinancialFormScreenW extends StatefulWidget {
  const FinancialFormScreenW({super.key});

  @override
  State<FinancialFormScreenW> createState() => _FinancialFormState();
}

class _FinancialFormState extends State<FinancialFormScreenW> {
  String itsId = '30445124';
  final FormController controller = Get.find<FormController>();
  late SuperTooltipController tooltipControllers;

  @override
  void initState() {
    super.initState();
    //Api.fetchProxiedData(
    //  'https://paktalim.com/admin/ws_app/GetProfileEducation/${itsId}?access_key=8803c22b50548c9d5b1401e3ab5854812c4dcacb&username=40459629&password=1107865253');
  }

  // RxBool to track expanded state
  final RxBool isFinancialExpanded = false.obs;
  final RxBool isPersonalAssetsExpanded = false.obs;
  final RxBool isBusinessAssetExpanded = false.obs;
  final RxBool isFamilyEduExpanded = false.obs;
  final RxInt selectedRadio = 0.obs; // Default: No radio selected
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text("Financial Information",style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xfffffcf6),
      ),
      backgroundColor: Color(0xfffffcf6),
      body: ListView(
        children: [
          _buildCollapsibleSection("Financials", isFinancialExpanded, financialInfo,complete: controller.isFinancialComplete),
          if(controller.organization.value=='stsmf')...[
            _buildCollapsibleSection(
                "Personal Assets", isPersonalAssetsExpanded, personalAssetsInfo,
                complete: controller.isPersonalAssetsComplete),
            _buildCollapsibleSection("Business Assets", isBusinessAssetExpanded,
                _businessAssetSection,
                complete: controller.isBusinessAssetComplete),
          ],
    //_buildCollapsibleSection("Family Education", isFamilyEduExpanded, _familyEducationSection,complete: controller.isFamilyEduComplete),
          Obx(() => Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (controller.checkFinancialInfo())
                  ? () {
                // Handle next action here
              }
                  : null, // Disabled if form is invalid
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.checkFinancialInfo()
                    ? Colors.brown
                    : Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Icon(
                    Icons.navigate_next_rounded,
                    color: Colors.white,
                    size: 24,
                  )
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// **Function to build collapsible sections with animation**
  Widget _buildCollapsibleSection(
      String title, RxBool isExpanded, Widget Function() content,{RxBool? complete}) {
    return Obx(() => Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
                color: complete!.value ? Colors.green : Colors.transparent,
                width: 2
            ),
            borderRadius: BorderRadius.circular(8),
            color: Color(0xffffead1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  isExpanded.value =
                  !isExpanded.value; // Toggle expand/collapse
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.brown)),
                      ],
                    ),
                    Row(
                      children: [

                        AnimatedRotation(
                          turns: isExpanded.value
                              ? 0.5
                              : 0.0, // Rotates 180° when expanded
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            // Keep only one icon and rotate it
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 20, color: Colors.white, thickness: 2),
              AnimatedSize(
                alignment: Alignment.topCenter,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded.value ? content() : SizedBox.shrink(),
              ),
            ],
          ),
        ),
        if (complete.value)
          Positioned(
            top: 0,
            right: 25,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Text(
                "Completed",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    ));
  }

  Widget financialInfo() {
    int total = (int.tryParse(controller.personalIncome.value) ?? 0) + (int.tryParse(controller.otherFamilyIncome.value) ?? 0) + (int.tryParse(controller.studentIncome.value) ?? 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total: $total",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        Container(
          //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xffffead1),
          ),
          child: Column(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    //color: const Color(0xffffead1),
                    color: Color(0xffecdacc)
                  //border: Border.all(color:Colors.grey,width: 1)
                ),
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Income",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.brown),
                    ),
                    Row(
                      spacing: 15,
                      children: [
                        Flexible(child: _buildField("Personal Income", controller.personalIncome,function: ()=> controller.validateFinancialAssetsFields())),
                        Flexible(child: _buildField("Other Family Income", controller.otherFamilyIncome,function: ()=> controller.validateFinancialAssetsFields())),
                        Flexible(
                          child: _buildField(
                              "Student Income (Part Time)", controller.studentIncome,function: ()=> controller.validateFinancialAssetsFields()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    //color: const Color(0xffffead1),
                    color: Color(0xffecdacc)
                  //border: Border.all(color:Colors.grey,width: 1)
                ),
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Residential Property",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.brown),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Obx(() => Radio(
                                value: 1,
                                groupValue: selectedRadio.value,
                                onChanged: (value) {
                                  controller.rentProperty.value = '';
                                  controller.goodwillProperty.value = '';
                                  selectedRadio.value = value as int;
                                },
                              )),
                              Expanded(
                                child: Obx(() => _buildField(
                                  "Owned",
                                  function: ()=> controller.validateFinancialAssetsFields(),
                                  controller.ownedProperty,
                                  isEnabled: selectedRadio.value ==
                                      1, // Enable when radio is checked
                                )),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            children: [
                              Obx(() => Radio(
                                value: 2,
                                groupValue: selectedRadio.value,
                                onChanged: (value) {
                                  selectedRadio.value = value as int;
                                  controller.ownedProperty.value = '';
                                  controller.goodwillProperty.value = '';

                                },
                              )),
                              Expanded(
                                child: Obx(() => _buildField(
                                  "Rent",
                                  function: ()=> controller.validateFinancialAssetsFields(),
                                  controller.rentProperty,
                                  isEnabled: selectedRadio.value ==
                                      2, // Enable when radio is checked
                                )),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            children: [
                              Obx(() => Radio(
                                value: 3,
                                groupValue: selectedRadio.value,
                                onChanged: (value) {
                                  selectedRadio.value = value as int;
                                  controller.ownedProperty.value = '';
                                  controller.rentProperty.value = '';
                                },
                              )),
                              Expanded(
                                child: Obx(() => _buildField(
                                  "Goodwill",
                                  function: ()=> controller.validateFinancialAssetsFields(),
                                  controller.goodwillProperty,
                                  isEnabled: selectedRadio.value ==
                                      3, // Enable when radio is checked
                                )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget personalAssetsInfo() {
    int total = (int.tryParse(controller.property.value) ?? 0) + (int.tryParse(controller.jewelry.value) ?? 0) + (int.tryParse(controller.transport.value) ?? 0) + (int.tryParse(controller.others.value) ?? 0);
    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffffead1),
      ),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total: $total",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black)),
          Row(
            spacing: 15,
            children: [
              Flexible(child: _buildField("Property", controller.property,function: ()=> controller.validatePersonalAssetsFields())),
              Flexible(child: _buildField("Jewelry", controller.jewelry,function: ()=> controller.validatePersonalAssetsFields())),
              Flexible(child: _buildField("Transport", controller.transport,function: ()=> controller.validatePersonalAssetsFields())),
              Flexible(child: _buildField("Others", controller.others,function: ()=> controller.validatePersonalAssetsFields())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _businessAssetSection() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Business & Assets",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        Row(
          children: [
            Obx(() => Radio(
              value: 1,
              toggleable: true,
              groupValue: controller.businesAssetInt.value,
              onChanged: (value) {
                if (value == null) {
                  controller.businesAssetInt.value = 0;
                } else {
                  controller.businesAssetInt.value = value;
                  controller.validateBusinessAssetsFields();
                }
              },
            )),
            Text("No Business / Doing Job",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
          ],
        ),
        if(controller.businesAssetInt.value==0)
        Obx(() => Column(
          spacing: 15,
          children: List.generate(controller.businessList.length, (index) {
            RxString businessName = controller.businessList[index]["businessName"];
            RxString assetValue = controller.businessList[index]["assetValue"];

            return Row(
              children: [
                Expanded(
                  child: Column(
                    spacing: 8,
                    children: [
                      Row(
                        spacing:15,
                        children: [
                          Flexible(
                            child: _buildField(
                                "Business Name",
                                businessName,
                                isEnabled: true,
                                function: ()=> controller.validateBusinessAssetsFields()
                            ),
                          ),
                          Flexible(
                            child: _buildField(
                                "Asset Value",
                                assetValue,
                                isEnabled: true,
                                function: ()=> controller.validateBusinessAssetsFields()
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    controller.businessList.removeAt(index);
                    controller.validateBusinessAssetsFields();
                  },
                ),
              ],
            );
          }),
        )),
        if(controller.businesAssetInt.value==0)
          TextButton.icon(
          onPressed: () {
            bool allValid = controller.businessList.every((entry) =>
            entry["businessName"].value.isNotEmpty &&
                entry["assetValue"].value.isNotEmpty);

            if (!allValid) {
              return;
            }
            controller.businessList.add({"businessName": "".obs, "assetValue": "".obs});
            controller.validateBusinessAssetsFields();
          },
          icon: Icon(Icons.add,color: Colors.green,size: 20,),
          label: Text("Add Business",style: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),),
        ),
        SizedBox(height: 10,)
      ],
    );
  }

  Widget _familyEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Family Member Education",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        SizedBox(height: 10),
        Obx(() => Column(
          children: List.generate(controller.familyEducationList.length, (index) {
            RxString name = controller.familyEducationList[index]["name"];
            RxString age = controller.familyEducationList[index]["age"];
            RxString institute = controller.familyEducationList[index]["institute"];
            RxString studentClass = controller.familyEducationList[index]["class"];
            RxString fees = controller.familyEducationList[index]["fees"];
            RxString remarks = controller.familyEducationList[index]["remarks"];

            return Column(
              spacing: 8,
              children: [
                _buildField("Name", name, isEnabled: true,function: ()=> controller.validateFamilyEduFields()),
                Row(
                  spacing: 5,
                  children: [
                    Flexible(flex:3,child: _buildField("Age", age, isEnabled: true,function: ()=> controller.validateFamilyEduFields())),
                    Flexible(flex:5,child: _buildField("Class / Degree", studentClass, isEnabled: true,function: ()=> controller.validateFamilyEduFields())),
                  ],
                ),
                _buildField("Institute Name", institute, isEnabled: true,function: ()=> controller.validateFamilyEduFields()),
                _buildField("Fees", fees, isEnabled: true,function: ()=> controller.validateFamilyEduFields()),
                _buildField("Remarks", remarks, isEnabled: true,height: 100,function: ()=> controller.validateFamilyEduFields()),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    controller.familyEducationList.removeAt(index);
                    controller.validateFamilyEduFields();
                  },
                ),
                Divider(thickness: 1, color: Colors.brown),
              ],
            );
          }),
        )),
        SizedBox(height: 10),
        // ✅ Button to Add New Family Member's Education
        TextButton.icon(
          onPressed: () {
            bool allValid = controller.familyEducationList.every((entry) =>
            entry["name"].value.isNotEmpty &&
                entry["age"].value.isNotEmpty &&
                entry["institute"].value.isNotEmpty &&
                entry["class"].value.isNotEmpty &&
                entry["fees"].value.isNotEmpty &&
                entry["remarks"].value.isNotEmpty);

            if (!allValid) {
              return;
            }

            controller.familyEducationList.add({
              "name": "".obs,
              "age": "".obs,
              "institute": "".obs,
              "class": "".obs,
              "fees": "".obs,
              "remarks": "".obs
            });
            controller.validateFamilyEduFields();
          },
          icon: Icon(Icons.add,color: Colors.green,size: 20,),
          label: Text("Add Family Member",style: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),),
        ),
      ],
    );
  }

  Widget _buildField(String label, RxString rxValue,
      {double? height, bool? isEnabled, Function()? function}) {
    bool isDescription = height != null;
    SuperTooltipController tooltipController = SuperTooltipController();

    return Obx(() {
      String? error = controller.validateField(label, rxValue.value);
      bool isEmpty = rxValue.value.trim().isEmpty;
      bool isValid = error == null && !isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height ?? 50,
            child: TextFormField(
              enabled: isEnabled ?? true,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.brown,
              controller: TextEditingController(text: rxValue.value)
                ..selection =
                TextSelection.collapsed(offset: rxValue.value.length),
              onChanged: (value) {
                rxValue.value = value;
                controller.validateForm();
                function?.call();
              },
              textCapitalization: TextCapitalization.sentences,
              maxLines: isDescription ? 3 : 1,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: isValid
                    ? Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                )
                    : GestureDetector(
                  onTap: () async {
                    if (!isValid && !isEmpty) {
                      await tooltipController.showTooltip();
                    }
                  },
                  child: SuperTooltip(
                    elevation: 1,
                    showBarrier: true,
                    barrierColor: Colors.transparent,
                    controller: tooltipController,
                    arrowTipDistance: 10,
                    arrowTipRadius: 2,
                    arrowLength: 10,
                    borderColor: isEmpty
                        ? Colors.amber // ⚠️ Yellow for info
                        : Colors.red, // ❌ Red for error
                    borderWidth: 2,
                    backgroundColor: isEmpty
                        ? Colors.amber.withValues(alpha: 0.9) // ⚠️ Yellow
                        : Colors.red.withValues(alpha: 0.9), // ❌ Red
                    boxShadows: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.2), // Light shadow
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                    toggleOnTap: true,
                    content: Text(
                      isEmpty ? "This field is required" : error ?? "",
                      style: const TextStyle(
                          color: Colors.black, fontSize: 12),
                    ),
                    child: Icon(
                      isEmpty
                          ? Icons.info_rounded // ⚠️ Yellow info icon
                          : Icons.error_rounded, // ❌ Red error icon
                      color: isEmpty ? Colors.amber : Colors.red,
                    ),
                  ),
                ),
                labelText: label,
                labelStyle:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.grey), // Grey border when disabled
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: (isEnabled ?? true) ? const Color(0xfffffcf6) : Colors.grey[300], // Lighter color for disabled                //contentPadding: EdgeInsets.zero
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDropdown({
    required String label,
    required Rxn<int> selectedValue,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    required bool isEnabled,
  }) {
    SuperTooltipController tooltipController = SuperTooltipController();
    String? error = controller.validateDropdown(label, selectedValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => DropdownButtonFormField2<int>(
          value: selectedValue.value,
          decoration: InputDecoration(
            suffixIcon: error == null
                ? SizedBox.shrink()
                : GestureDetector(
              onTap: () async {
                await tooltipController.showTooltip();
              },
              child: SuperTooltip(
                elevation: 1,
                //showBarrier: true, // Allows tapping outside to close
                barrierColor: Colors
                    .transparent, // Keep it visible without dark overlay
                showBarrier: true,
                controller: tooltipController,
                arrowTipDistance: 10,
                arrowTipRadius: 2,
                arrowLength: 10,
                borderColor: Color(0xffE9D502),
                borderWidth: 2,
                backgroundColor:
                Color(0xffE9D502).withValues(alpha: 0.9),
                boxShadows: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.2), // Light shadow color
                    blurRadius: 6, // Soft blur effect
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
                toggleOnTap: true,
                content: Text(error,
                    style: const TextStyle(
                        color: Colors.black, fontSize: 12)),
                child: Icon(
                  Icons.error,
                  color: Color(0xffE9D502),
                ),
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            label: Text(label),
            labelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  width: 1, color: Colors.brown), // Removes the border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(width: 1, color: Colors.brown),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                  color: Color(0xfffffcf6),
                  borderRadius: BorderRadius.circular(8))),
          items: items.map((Map<String, dynamic> item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(item['name']),
            );
          }).toList(),
          onChanged: isEnabled
              ? (value) {
            selectedValue.value = value;
            onChanged(value);
            controller.validateForm();
          }
              : null, // Disable when needed
          //disabledHint: Text("Select ${_getDisabledHint(label)}"),
        )),
      ],
    );
  }
}
