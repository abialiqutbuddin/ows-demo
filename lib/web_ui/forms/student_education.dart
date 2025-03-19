import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../api/api.dart';
import '../../controller/forms/form_screen_controller.dart';

class StudentEducationW extends StatefulWidget {
  const StudentEducationW({super.key});

  @override
  State<StudentEducationW> createState() => _StudentEducationState();
}

class _StudentEducationState extends State<StudentEducationW> {
  String itsId = '30445124';
  final FormController controller = Get.find<FormController>();
  late SuperTooltipController tooltipControllers;
  List<Map<String, dynamic>> goodsList = [];
  List<Map<String, dynamic>> selectedGoods = [];

  @override
  void initState() {
    super.initState();
    fetchGoods();
    //Api.fetchProxiedData(
    //  'https://paktalim.com/admin/ws_app/GetProfileEducation/${itsId}?access_key=8803c22b50548c9d5b1401e3ab5854812c4dcacb&username=40459629&password=1107865253');
  }

  // RxBool to track expanded state
  final RxBool isstudentEduExpanded = false.obs;
  final RxBool isStandardofLivingExpanded = false.obs;
  final RxBool isBusinessAssetExpanded = false.obs;
  final RxBool isTravellingExpanded = false.obs;
  final RxBool isDependentsExpanded = false.obs;
  final RxBool isLiabilitiesExpanded = false.obs;
  final RxBool isEnayatExpanded = false.obs;
  final RxBool isAppliedSectionExpanded = false.obs;
  final RxBool isPaymentsSectionExpanded = false.obs;
  final RxBool isRepaymentsSectionExpanded = false.obs;

  Future<void> fetchGoods() async {
    try {
      final goods = await Api.fetchGoods();
      setState(() {
        goodsList = goods;
        selectedGoods = goodsList
            .map((good) =>
                {'good_id': good['good_id'], 'selected': 'none', 'comment': ''})
            .toList();
      });
    } catch (e) {
      print("Error fetching goods: $e");
    }
  }

  Widget travellingSection() {
    return Container(
      width: double.infinity,
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
            "Places",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
          ),
          Row(
            children: [
              Obx(() => Radio(
                    value: 1,
                    toggleable: true,
                    groupValue: controller.travelledInt.value,
                    onChanged: (value) {
                      if (value == null) {
                        controller.travelledInt.value = 0;
                      } else {
                        controller.travelledInt.value = value;
                        controller.validateTravellingsFields();
                      }
                    },
                  )),
              Text(
                "Not Travelled",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
          if (controller.travelledInt.value != 1)
            Obx(() => Column(
                  children:
                      List.generate(controller.travelling.length, (index) {
                    RxString place = controller.travelling[index]["place"];
                    RxString year = controller.travelling[index]["year"];
                    RxString purpose = controller.travelling[index]["purpose"];

                    return Row(
                      spacing: 8,
                      children: [
                        Text(
                          "${index + 1}.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Row(
                            spacing: 5,
                            children: [
                              Flexible(
                                  flex: 4,
                                  child: _buildField("Place", place,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateTravellingsFields())),
                              Flexible(
                                  flex: 2,
                                  child: _buildField("Year", year,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateTravellingsFields())),
                              Flexible(
                                  flex: 4,
                                  child: _buildField("Purpose", purpose,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateTravellingsFields())),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            controller.travelling.removeAt(index);
                            controller.validateTravellingsFields();
                          },
                        ),
                        //Divider(thickness: 1, color: Colors.brown),
                      ],
                    );
                  }),
                )),
          if (controller.travelledInt.value != 1)
            TextButton.icon(
              onPressed: () {
                bool allValid = controller.travelling.every((entry) =>
                    entry["place"].value.isNotEmpty &&
                    entry["year"].value.isNotEmpty &&
                    entry["purpose"].value.isNotEmpty);
                if (!allValid) {
                  return;
                }
                controller.travelling.add({
                  "place": "".obs,
                  "year": "".obs,
                  "purpose": "".obs,
                });
                controller.validateTravellingsFields();
              },
              icon: Icon(
                Icons.add,
                color: Colors.green,
                size: 20,
              ),
              label: Text(
                "Add New",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget dependentsSection() {
    return Container(
      width: double.infinity,
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
            "Dependents",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
          ),
          Row(
            children: [
              Obx(() => Radio(
                    value: 1,
                    toggleable: true,
                    groupValue: controller.dependentsInt.value,
                    onChanged: (value) {
                      if (value == null) {
                        controller.dependentsInt.value = 0;
                      } else {
                        controller.dependentsInt.value = value;
                        controller.validateDependentsFields();
                      }
                    },
                  )),
              Text(
                "No Dependents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
          if (controller.dependentsInt.value != 1)
            Obx(() => Column(
                  children:
                      List.generate(controller.dependents.length, (index) {
                    RxString place = controller.dependents[index]["name"];
                    RxString year = controller.dependents[index]["relation"];
                    RxString purpose = controller.dependents[index]["age"];

                    return Row(
                      spacing: 8,
                      children: [
                        Text(
                          "${index + 1}.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Row(
                            spacing: 8,
                            children: [
                              Flexible(
                                child: _buildField("Name", place,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validateDependentsFields()),
                              ),
                              Flexible(
                                child: _buildField("Relation", year,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validateDependentsFields()),
                              ),
                              Flexible(
                                  child: _buildField("Age", purpose,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateDependentsFields())),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            controller.dependents.removeAt(index);
                            controller.validateDependentsFields();
                          },
                        ),
                        //Divider(thickness: 1, color: Colors.brown),
                      ],
                    );
                  }),
                )),
          if (controller.dependentsInt.value != 1)
            TextButton.icon(
              onPressed: () {
                bool allValid = controller.dependents.every((entry) =>
                    entry["name"].value.isNotEmpty &&
                    entry["relation"].value.isNotEmpty &&
                    entry["age"].value.isNotEmpty);
                if (!allValid) {
                  return;
                }
                controller.dependents.add({
                  "name": "".obs,
                  "relation": "".obs,
                  "age": "".obs,
                });
                controller.validateDependentsFields();
              },
              icon: Icon(
                Icons.add,
                color: Colors.green,
                size: 20,
              ),
              label: Text(
                "Add New",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget liabilitiesSection() {
    return Container(
      width: double.infinity,
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
            "Liabilities",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
          ),
          Row(
            children: [
              Obx(() => Radio(
                    value: 1,
                    toggleable: true,
                    groupValue: controller.liabilitiesInt.value,
                    onChanged: (value) {
                      if (value == null) {
                        controller.liabilitiesInt.value = 0;
                      } else {
                        controller.liabilitiesInt.value = value;
                        controller.validateLiabilitiesFields();
                      }
                    },
                  )),
              Text(
                "No Liabilities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
          if (controller.liabilitiesInt.value != 1)
            Obx(() => Column(
                  children:
                      List.generate(controller.liabilities.length, (index) {
                    RxString type = controller.liabilities[index]["type"];
                    RxString its = controller.liabilities[index]["its"];
                    RxString purpose = controller.liabilities[index]["purpose"];
                    RxString amount = controller.liabilities[index]["amount"];
                    RxString balance = controller.liabilities[index]["balance"];
                    RxString status = controller.liabilities[index]["status"];
                    RxString reason = controller.liabilities[index]["reason"];

                    return Row(
                      spacing: 8,
                      children: [
                        Text(
                          "${index + 1}.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),

                        Expanded(
                          child: Column(
                            spacing: 8,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Flexible(
                                      child: _buildField("QH Type / From", type,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateLiabilitiesFields())),
                                  Flexible(
                                      child: _buildField(
                                          "ITS (Mother / Father)", its,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateLiabilitiesFields())),
                                  Flexible(
                                      child: _buildField("Purpose", purpose,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateLiabilitiesFields())),
                                  Flexible(
                                      child: _buildField("Amount", amount,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateLiabilitiesFields())),
                                ],
                              ),
                              Row(
                                spacing: 8,
                                children: [
                                  Flexible(
                                      child: _buildField("Balance", balance,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateLiabilitiesFields())),
                                  Flexible(
                                      child: _buildField("Status", status,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateLiabilitiesFields())),
                                  Flexible(
                                      child: _buildField(
                                          "Reason if delay in Payment", reason,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateLiabilitiesFields())),
                                ],
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            controller.liabilities.removeAt(index);
                            controller.validateLiabilitiesFields();
                          },
                        ),
                        //Divider(thickness: 1, color: Colors.brown),
                      ],
                    );
                  }),
                )),
          if (controller.liabilitiesInt.value != 1)
            TextButton.icon(
              onPressed: () {
                bool allValid = controller.liabilities.every((entry) =>
                    entry["type"].value.isNotEmpty &&
                    entry["its"].value.isNotEmpty &&
                    entry["purpose"].value.isNotEmpty &&
                    entry["amount"].value.isNotEmpty &&
                    entry["balance"].value.isNotEmpty &&
                    entry["status"].value.isNotEmpty);
                if (!allValid) {
                  return;
                }
                controller.liabilities.add({
                  "type": "".obs,
                  "its": "".obs,
                  "purpose": "".obs,
                  "amount": "".obs,
                  "balance": "".obs,
                  "status": "".obs,
                  "reason": "".obs,
                });
                controller.validateLiabilitiesFields();
              },
              icon: Icon(
                Icons.add,
                color: Colors.green,
                size: 20,
              ),
              label: Text(
                "Add New",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget enayatSection() {
    return Container(
      width: double.infinity,
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
            "Enayat",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
          ),
          Row(
            children: [
              Obx(() => Radio(
                    value: 1,
                    toggleable: true,
                    groupValue: controller.enayatInt.value,
                    onChanged: (value) {
                      if (value == null) {
                        controller.enayatInt.value = 0;
                      } else {
                        controller.enayatInt.value = value;
                        controller.validateEnayatFromFields();
                      }
                    },
                  )),
              Text(
                "No Previous Enayat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
          if (controller.enayatInt.value != 1)
            Obx(() => Column(
                  children: List.generate(controller.enayat.length, (index) {
                    RxString its = controller.enayat[index]["its"];
                    RxString purpose = controller.enayat[index]["purpose"];
                    RxString amount = controller.enayat[index]["amount"];
                    RxString date = controller.enayat[index]["date"];

                    return Row(
                      spacing: 8,
                      children: [
                        Text(
                          "${index + 1}.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Expanded(
                          child: Row(
                            spacing: 8,
                            children: [
                              Flexible(
                                  child: _buildField("ITS", its,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateEnayatFromFields())),
                              Flexible(
                                  child: _buildField("Purpose", purpose,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateEnayatFromFields())),
                              Flexible(
                                  child: _buildField("Amount", amount,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateEnayatFromFields())),
                              Flexible(
                                  child: _buildField("Date", date,
                                      isEnabled: true,
                                      function: () => controller
                                          .validateEnayatFromFields())),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            controller.enayat.removeAt(index);
                            controller.validateEnayatFromFields();
                          },
                        ),
                        //Divider(thickness: 1, color: Colors.brown),
                      ],
                    );
                  }),
                )),
          if (controller.enayatInt.value != 1)
            TextButton.icon(
              onPressed: () {
                bool allValid = controller.enayat.every((entry) =>
                    entry["its"].value.isNotEmpty &&
                    entry["purpose"].value.isNotEmpty &&
                    entry["amount"].value.isNotEmpty &&
                    entry["date"].value.isNotEmpty);
                if (!allValid) {
                  return;
                }
                controller.enayat.add({
                  "its": "".obs,
                  "purpose": "".obs,
                  "amount": "".obs,
                  "date": "".obs,
                });
                controller.validateEnayatFromFields();
              },
              icon: Icon(
                Icons.add,
                color: Colors.green,
                size: 20,
              ),
              label: Text(
                "Add New",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget qhAppliedSection() {
    return Column(
      spacing: 8,
      children: [
        Row(
          children: [
            Obx(() => Radio(
                  value: 1,
                  toggleable: true,
                  groupValue: controller.qhappliedInt.value,
                  onChanged: (value) {
                    if (value == null) {
                      controller.qhappliedInt.value = 0;
                    } else {
                      controller.qhappliedInt.value = value;
                      controller.validateQHAppliedFields();
                    }
                  },
                )),
            Text(
              "No Previously QH Taken",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
        if (controller.qhappliedInt.value != 1)
          Row(
            spacing: 8,
            children: [
              Flexible(
                  child: _buildField("QH Applied", controller.appliedAmount,
                      isEnabled: true,
                      function: () => controller.validateQHAppliedFields())),
              Flexible(
                  child: _buildField("Amanat", controller.amanat,
                      isEnabled: true,
                      function: () => controller.validateQHAppliedFields())),
            ],
          ),
        if (controller.qhappliedInt.value != 1)
          Container(
            width: double.infinity,
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
                  "Guarantors",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),
                ),
                Obx(() => Column(
                      children:
                          List.generate(controller.guarantor.length, (index) {
                        RxString name = controller.guarantor[index]["name"];
                        RxString its = controller.guarantor[index]["its"];
                        RxString mobile = controller.guarantor[index]["mobile"];

                        return Row(
                          spacing: 8,
                          children: [
                            Text(
                              "${index + 1}.",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Expanded(
                              child: Row(
                                spacing: 8,
                                children: [
                                  Flexible(
                                      child: _buildField("Name", name,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateQHAppliedFields())),
                                  Flexible(
                                      child: _buildField("ITS", its,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateQHAppliedFields())),
                                  Flexible(
                                      child: _buildField(
                                          "Mobile Number", mobile,
                                          isEnabled: true,
                                          function: () => controller
                                              .validateQHAppliedFields())),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.guarantor.removeAt(index);
                                controller.validateQHAppliedFields();
                              },
                            ),
                            //Divider(thickness: 1, color: Colors.brown),
                          ],
                        );
                      }),
                    )),
                TextButton.icon(
                  onPressed: () {
                    bool allValid = controller.guarantor.every((entry) =>
                        entry["name"].value.isNotEmpty &&
                        entry["its"].value.isNotEmpty &&
                        entry["mobile"].value.isNotEmpty);
                    if (!allValid) {
                      return;
                    }
                    controller.guarantor.add({
                      "name": "".obs,
                      "its": "".obs,
                      "mobile": "".obs,
                    });
                    controller.validateQHAppliedFields();
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 20,
                  ),
                  label: Text(
                    "Add New",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget paymentsSection() {
    return Container(
      width: double.infinity,
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
            "Payments",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
          ),
          Obx(() => Column(
                children: List.generate(controller.payments.length, (index) {
                  RxString amount = controller.payments[index]["amount"];
                  RxString date = controller.payments[index]["date"];

                  return Row(
                    spacing: 8,
                    children: [
                      Text(
                        "Semester ${index + 1} Class",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Expanded(
                        child: Row(
                          spacing: 8,
                          children: [
                            Flexible(
                                child: _buildField("Amount", amount,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validatePaymentsFields())),
                            Flexible(
                                child: _buildField("Date", date,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validatePaymentsFields())),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.payments.removeAt(index);
                          controller.validatePaymentsFields();
                        },
                      ),
                      //Divider(thickness: 1, color: Colors.brown),
                    ],
                  );
                }),
              )),
          TextButton.icon(
            onPressed: () {
              bool allValid = controller.payments.every((entry) =>
                  entry["amount"].value.isNotEmpty &&
                  entry["date"].value.isNotEmpty);
              if (!allValid) {
                return;
              }
              controller.payments.add({
                "amount": "".obs,
                "date": "".obs,
              });
              controller.validatePaymentsFields();
            },
            icon: Icon(
              Icons.add,
              color: Colors.green,
              size: 20,
            ),
            label: Text(
              "Add New",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget repaymentsSection() {
    return Container(
      width: double.infinity,
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
            "Repayments",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
          ),
          Obx(() => Column(
                children: List.generate(controller.repayments.length, (index) {
                  RxString amount = controller.repayments[index]["amount"];
                  RxString date = controller.repayments[index]["date"];
                  RxString total = controller.repayments[index]["total"];
                  RxString balance = controller.repayments[index]["balance"];

                  return Row(
                    spacing: 8,
                    children: [
                      Text(
                        "${index + 1}.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Expanded(
                        child: Row(
                          spacing: 8,
                          children: [
                            Flexible(
                                child: _buildField("Amount", amount,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validateRePaymentsFields())),
                            Flexible(
                                child: _buildField("Date", date,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validateRePaymentsFields())),
                            Flexible(
                                child: _buildField("Total", total,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validateRePaymentsFields())),
                            Flexible(
                                child: _buildField("Balance", balance,
                                    isEnabled: true,
                                    function: () =>
                                        controller.validateRePaymentsFields())),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.repayments.removeAt(index);
                          controller.validateRePaymentsFields();
                        },
                      ),

                      //Divider(thickness: 1, color: Colors.brown),
                    ],
                  );
                }),
              )),
          TextButton.icon(
            onPressed: () {
              bool allValid = controller.repayments.every((entry) =>
                  entry["amount"].value.isNotEmpty &&
                  entry["date"].value.isNotEmpty &&
                  entry["total"].value.isNotEmpty &&
                  entry["balance"].value.isNotEmpty);
              if (!allValid) {
                return;
              }
              controller.repayments.add({
                "amount": "".obs,
                "date": "".obs,
                "total": "".obs,
                "balance": "".obs,
              });
              controller.validateRePaymentsFields();
            },
            icon: Icon(
              Icons.add,
              color: Colors.green,
              size: 20,
            ),
            label: Text(
              "Add New",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, TextEditingController> commentControllers = {};
  bool allSelected = false;

  void toggleSelection(int goodId, String selection) {
    setState(() {
      final index =
          selectedGoods.indexWhere((item) => item['good_id'] == goodId);
      if (index != -1) {
        selectedGoods[index]['selected'] = selection;
      }
      checkIfAllSelected();
    });
  }

  void updateComment(int goodId, String comment) {
    final index = selectedGoods.indexWhere((item) => item['good_id'] == goodId);
    if (index != -1) {
      selectedGoods[index]['comment'] = comment;
    }
  }

  // Check if all items are either "yes" or "no"
  void checkIfAllSelected() {
    bool allAnswered = selectedGoods
        .every((item) => item['selected'] == 'yes' || item['selected'] == 'no');
    setState(() {
      allSelected = allAnswered;
    });
    if (allSelected == true) {
      controller.isSOLComplete.value = true;
    } else {
      controller.isSOLComplete.value = false;
    }
  }

  @override
  void dispose() {
    for (var controller in commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget goods() {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: ListView.builder(
        //itemExtent: 80, // Fixes item height for better performance
        physics: BouncingScrollPhysics(),
        itemCount: goodsList.length,
        itemBuilder: (context, index) {
          final good = goodsList[index];
          final selectedIndex = selectedGoods
              .indexWhere((item) => item['good_id'] == good['good_id']);
          final selectedValue = selectedIndex != -1
              ? selectedGoods[selectedIndex]['selected']
              : 'no';
          final comment = selectedIndex != -1
              ? selectedGoods[selectedIndex]['comment']
              : '';

          final controller = commentControllers.putIfAbsent(
            good['good_id'],
            () => TextEditingController(text: comment),
          );

          return Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 200,
                    child: Text(good['description'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ))),
                // Radio Buttons for "Yes" and "No"
                Flexible(
                  child: StatefulBuilder(
                    builder: (context, setLocalState) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: "yes",
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setLocalState(
                                  () {}); // Only updates this part, reducing UI lag
                              toggleSelection(good['good_id'], value!);
                            },
                          ),
                          Text("Yes"),
                          Radio<String>(
                            value: "no",
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setLocalState(() {});
                              toggleSelection(good['good_id'], value!);
                            },
                          ),
                          Text("No"),
                        ],
                      );
                    },
                  ),
                ),

                // Comment Box
                Flexible(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "Add comment",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        updateComment(good['good_id'], text);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          "Financial Information",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xfffffcf6),
      ),
      backgroundColor: Color(0xfffffcf6),
      body: ListView(
        children: [
          //_buildCollapsibleSection("Student Education", isstudentEduExpanded, studentEducation),
          if (controller.organization.value == 'aiut')
            _buildCollapsibleSection(
                "Standard of living", isStandardofLivingExpanded, goods,
                complete: controller.isSOLComplete),
          _buildCollapsibleSection("Travelling (Last 5 Years)",
              isTravellingExpanded, travellingSection,
              complete: controller.isTravellingComplete),
          _buildCollapsibleSection(
              "Dependents", isDependentsExpanded, dependentsSection,
              complete: controller.isDependentsComplete),
          if (controller.organization.value == 'stmsf') ...[
            _buildCollapsibleSection(
                "Liabilities", isLiabilitiesExpanded, liabilitiesSection,
                complete: controller.isLiabilitesComplete),
            _buildCollapsibleSection(
                "Previously Taken", isAppliedSectionExpanded, qhAppliedSection,
                complete: controller.isQHAppliedComplete),
          ],
          if (controller.organization.value == 'stsmf' ||
              controller.organization.value == 'aiut')
            _buildCollapsibleSection(
                "Enayat From", isEnayatExpanded, enayatSection,
                complete: controller.isEnayatComplete),
          // _buildCollapsibleSection(
          //     "Payments", isPaymentsSectionExpanded, paymentsSection,
          //     complete: controller.isPaymentsComplete),
          // _buildCollapsibleSection(
          //     "Repayments", isRepaymentsSectionExpanded, repaymentsSection,
          //     complete: controller.isRepaymentsComplete),
          Obx(() => Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: controller.isButtonEnabled.value
                      ? () {
                          // Handle next action here
                        }
                      : null, // Disabled if form is invalid
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isButtonEnabled.value
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
      String title, RxBool isExpanded, Widget Function() content,
      {RxBool? complete}) {
    return Obx(() => Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xffffead1),
                  border: Border.all(
                      color:
                          complete!.value ? Colors.green : Colors.transparent,
                      width: 2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      isExpanded.value = !isExpanded.value;
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

  Widget studentEducation() {
    int index = 1;
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
                  "Religious",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Deeni",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sabaq",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hifzul Quran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tilawatul Quran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 6,
                            child: _buildField(
                                "Program", controller.personalIncome)),
                        Flexible(
                            flex: 3,
                            child:
                                _buildField("Year", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                //_buildField("Other Family Income", controller.otherFamilyIncome),
                //_buildField("Student Income (Part Time)", controller.studentIncome),
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
                  "General",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),
                ),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Masters",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildField("Program", controller.personalIncome),
                    _buildField("Institute", controller.personalIncome),
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                            flex: 1,
                            child:
                                _buildField("Year", controller.personalIncome)),
                        Flexible(
                            flex: 1,
                            child: _buildField(
                                "Grade", controller.personalIncome)),
                        Flexible(
                            flex: 1,
                            child:
                                _buildField("CGPA", controller.personalIncome)),
                      ],
                    ),
                  ],
                ),
                //_buildField("Personal Income", controller.personalIncome),
                //_buildField("Other Family Income", controller.otherFamilyIncome),
                //_buildField("Student Income (Part Time)", controller.studentIncome),
              ],
            ),
          ),
          Container(
            width: double.infinity,
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
                  "Other Certificationss",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown),
                ),
                Obx(() => Column(
                      children: List.generate(
                          controller.otherCertificationList.length, (index) {
                        RxString program =
                            controller.otherCertificationList[index]["program"];
                        RxString institute = controller
                            .otherCertificationList[index]["institute"];
                        RxString year =
                            controller.otherCertificationList[index]["year"];
                        RxString age =
                            controller.otherCertificationList[index]["age"];
                        RxString cgpa =
                            controller.otherCertificationList[index]["cgpa"];

                        return Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Container(
                                width: double.infinity,
                                child: Text(
                                  "${index + 1}.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            _buildField("Program", program, isEnabled: true),
                            _buildField("Institute", institute,
                                isEnabled: true),
                            Row(
                              spacing: 5,
                              children: [
                                Flexible(
                                    flex: 5,
                                    child: _buildField("Year", year,
                                        isEnabled: true)),
                                Flexible(
                                    flex: 4,
                                    child: _buildField("Age", age,
                                        isEnabled: true)),
                                Flexible(
                                    flex: 4,
                                    child: _buildField("CGPA", cgpa,
                                        isEnabled: true)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.otherCertificationList
                                    .removeAt(index);
                              },
                            ),
                            //Divider(thickness: 1, color: Colors.brown),
                          ],
                        );
                      }),
                    )),
                TextButton.icon(
                  onPressed: () {
                    bool allValid = controller.otherCertificationList.every(
                        (entry) =>
                            entry["program"].value.isNotEmpty &&
                            entry["institute"].value.isNotEmpty &&
                            entry["year"].value.isNotEmpty &&
                            entry["age"].value.isNotEmpty &&
                            entry["cgpa"].value.isNotEmpty);
                    if (!allValid) {
                      return;
                    }
                    controller.otherCertificationList.add({
                      "program": "".obs,
                      "institute": "".obs,
                      "year": "".obs,
                      "grade": "".obs,
                      "age": "".obs,
                      "cgpa": "".obs,
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 20,
                  ),
                  label: Text(
                    "Add Certification",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // Column(
                //   spacing: 10,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text("1.",style: TextStyle(fontWeight: FontWeight.bold),),
                //     _buildField("Program", controller.personalIncome),
                //     _buildField("Institute", controller.personalIncome),
                //     Row(
                //       spacing: 5,
                //       children: [
                //         Flexible(flex: 1,child: _buildField("Year", controller.personalIncome)),
                //         Flexible(flex: 1,child: _buildField("Grade", controller.personalIncome)),
                //         Flexible(flex: 1,child: _buildField("CGPA", controller.personalIncome)),
                //       ],
                //     ),
                //     TextButton.icon(
                //       onPressed: () {
                //         bool allValid = controller.otherCertificationList.every((entry) =>
                //         entry["program"].value.isNotEmpty &&
                //             entry["institute"].value.isNotEmpty &&
                //             entry["year"].value.isNotEmpty &&
                //             entry["grade"].value.isNotEmpty &&
                //             entry["cgpa"].value.isNotEmpty);
                //         if (!allValid) {
                //           return;
                //         }
                //         controller.otherCertificationList.add({
                //           "program": "".obs,
                //           "institute": "".obs,
                //           "year": "".obs,
                //           "grade": "".obs,
                //           "cgpa": "".obs,
                //         });
                //       },
                //       icon: Icon(Icons.add,color: Colors.green,size: 20,),
                //       label: Text("Add Certification",style: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),),
                //     ),
                //   ],
                // ),
                //_buildField("Personal Income", controller.personalIncome),
                //_buildField("Other Family Income", controller.otherFamilyIncome),
                //_buildField("Student Income (Part Time)", controller.studentIncome),
              ],
            ),
          ),
        ],
      ),
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
                  borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey), // Grey border when disabled
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                filled: true,
                fillColor: (isEnabled ?? true)
                    ? const Color(0xfffffcf6)
                    : Colors.grey[
                        300], // Lighter color for disabled                //contentPadding: EdgeInsets.zero
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
