import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ows/constants/app_routes.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import '../../api/api.dart';
import '../../constants/dummy_data.dart';
import '../../controller/state_management/state_manager.dart';
import '../../model/family_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../model/request_form_model.dart';
import '../widgets/alert.dart';

class Person {
  final String name;
  final String itsId;
  final String imageUrl;
  final Map<String, String> details;
  Person({
    required this.name,
    required this.itsId,
    required this.imageUrl,
    required this.details,
  });
}

final GlobalKey _globalKey = GlobalKey();

class ApplicationPdf extends StatefulWidget {
  final int id;

  const ApplicationPdf({super.key, required this.id});

  @override
  State<ApplicationPdf> createState() => _ApplicationPdfState();
}

class _ApplicationPdfState extends State<ApplicationPdf> {
  List<Map<String, dynamic>> excludedSections = [];
  Map<String, dynamic>? _cachedData;
  RequestFormModel? requestForm;
  RxBool isLoading = false.obs;
  RxBool hideLoading = false.obs;

  final pdf = pw.Document();
  late final Uint8List pdfBytes;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading.value = true;
    });
    final data = await fetchDetails(widget.id);
    requestForm = await Api.fetchRequestById(statecontroller.reqId.value);
    setState(() {
      _cachedData = data;
      isLoading.value = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndCreatePdf();
    });
  }

  Future<void> _encodeAndPrintPdf(Uint8List pngBytes) async {
    // decode the full screenshot
    final original = img.decodeImage(pngBytes)!;

    // Prepare a fresh PDF doc
    final pdf = pw.Document();

    // Compute how many pixels of the image correspond
    // to one A4 page height, preserving aspect ratio for full width:
    final pageWidthPt = PdfPageFormat.a4.width;
    final pageHeightPt = PdfPageFormat.a4.height;

    // calculate scale factor between PDF points and image pixels
    final scale = original.width / pageWidthPt;
    final sliceHeightPx = (pageHeightPt * scale).round();

    // slice the image vertically
    for (var offsetY = 0; offsetY < original.height; offsetY += sliceHeightPx) {
      final h = min(sliceHeightPx, original.height - offsetY);
      final slice = img.copyCrop(
        original,
        x: 0,
        y: offsetY,
        width: original.width,
        height: h,
      );
      final sliceBytes = Uint8List.fromList(img.encodePng(slice));
      final sliceImage = pw.MemoryImage(sliceBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Image(sliceImage, fit: pw.BoxFit.fitWidth),
            );
          },
        ),
      );
    }

    // now save, upload, etc.
    pdfBytes = await pdf.save();

    final success = await Api.uploadApplicationPdf(
      pdfBytes: pdfBytes,
      its: statecontroller.user.value.itsId.toString(),
      reqId: widget.id.toString(),
    );

    if (success) {
      Get.snackbar('✓', 'PDF uploaded successfully');
    } else {
      Get.snackbar('✗', 'PDF upload failed');
    }
  }

  Future<Map<String, dynamic>> fetchDetails(int id) async {
    final url = Uri.parse(
        'https://one-login.attalimiyah.com.pk/ows/api/keys-applications/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      _cachedData = data;
      return data;
    } else {
      throw Exception('Failed to load application details');
    }
  }

  Future<ui.Image?> _captureRawImage() async {
    final boundary =
        _globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: 1.0);
  }

  void _captureAndCreatePdf() async {
    isLoading.value = true;

    await Future.delayed(Duration(milliseconds: 500));

    // 1️⃣ Capture raw ui.Image (this still blocks briefly)
    final uiImage = await _captureRawImage();
    if (uiImage == null) {
      isLoading.value = false;
      return;
    }

    // 2️⃣ Convert to PNG in a background isolate
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 3️⃣ Offload PDF+print work to an isolate so UI thread stays free
    await compute(_encodeAndPrintPdf, pngBytes);
    isLoading.value = false;
  }

  ScreenshotController screenshotController = ScreenshotController();

  final GlobalStateController statecontroller =
      Get.find<GlobalStateController>();
  final double defSpacing = 8;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Application Preview"),
      //   actions: [
      //
      //   ],
      // ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.only(top: 20.0, left: 15, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Application Preview",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.black87),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Row(
                          spacing: 10,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008759),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              // icon: const Icon(Icons.picture_as_pdf),
                              // color: Colors.redAccent,
                              onPressed: () async {
                                await Printing.layoutPdf(
                                    onLayout: (_) => pdfBytes);

                                //_captureAndCreatePdf();
                                // TODO: implement PDF export
                              },
                              child: Text(
                                "PRINT PDF",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                        color: const Color(0xFF008759),
                                        width: 2),
                                  ),
                                ),
                                elevation: WidgetStateProperty.all(0),
                              ),
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.select_module),
                              child: Text("Go to Dashboard",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Screenshot(
                  controller: screenshotController,
                  key: _globalKey,
                  child: Column(
                    children: [
                      headerProfile(context),
                      if (father != null)
                        parentProfileSection("SECTION B: FATHER INFORMATION",
                            father!, requestForm!.fatherCnic),
                      if (mother != null)
                        parentProfileSection("SECTION C: MOTHER INFORMATION",
                            mother!, requestForm!.motherCnic),
                      buildContent(_cachedData!)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              decoration:
                  BoxDecoration(color: Colors.black.withValues(alpha: 0.4)),
              child: _showLoading())
        ],
      ),
    );
  }

  RxString title = "Preparing your application PDF".obs;
  RxString titleAfter = "PDF Ready".obs;
  RxString msg =
      "Preparing your application PDF. Please wait this might take 20-30 seconds. Do not exit!"
          .obs;
  RxString msgAfter = "Your Application PDF is ready!".obs;

  Widget _showLoading() {
    return Obx(
      () => !hideLoading.value
          ? Alert(
              preventBack: false,
              title: isLoading.value ? title.value : titleAfter.value,
              subtitle: isLoading.value ? msg.value : msgAfter.value,
              onOk: () {
                hideLoading.value = true;
              },
            )
          : SizedBox.shrink(),
    );
  }

  Widget headerProfile(BuildContext context) {
    final user = statecontroller.user.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'SECTION A: STUDENT INFORMATION',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Row: Image and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  Api.fetchImage(user.imageUrl ?? ''),
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: FlexColumnWidth(),
                    4: IntrinsicColumnWidth(),
                    5: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    _formRow3(
                        "Full Name",
                        user.fullName ?? '',
                        "ITS ID",
                        user.itsId?.toString() ?? '',
                        "Email",
                        user.email ?? ''),
                    _formRow3("Mobile No", user.mobileNo ?? '', "WhatsApp",
                        user.whatsappNo ?? '', "Jamiaat", user.jamiaat ?? ''),
                    _formRow3(
                        "Date of Birth",
                        user.dob ?? '',
                        "Age",
                        "${calculateAge(user.dob ?? '')} years",
                        "Address",
                        user.address ?? ''),
                    _formRow3('CNIC', requestForm?.cnic ?? '', '', '', '', '')
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          educationInfoSection(requestForm!)
        ],
      ),
    );
  }

  Widget parentProfileSection(String sectionTitle, Parent parent, String CNIC) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            sectionTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Row: Image and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  Api.fetchImage(parent.imageUrl!),
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: FlexColumnWidth(),
                    4: IntrinsicColumnWidth(),
                    5: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    _formRow3("Full Name", parent.fullName!, "ITS ID",
                        parent.itsId.toString(), "Email", parent.email!),
                    _formRow3("Mobile No", parent.mobileNo!, "WhatsApp",
                        parent.whatsappNo!, "Tanzeem", parent.tanzeem!),
                    _formRow3("Date of Birth", parent.dob!, "Age",
                        "${parent.age} years", "Address", parent.address!),
                    _formRow3("CNIC", CNIC, "", "", "", ""),
                  ],
                ),
              ),
            ],
          ),
          sectionTitle.contains('MOTHER')
              ? SingleOccupationCard(
                  subsectionTitle: 'Mother Occupation',
                  excludedSections: excludedSections,
                )
              : SingleOccupationCard(
                  subsectionTitle: 'Father Occupation',
                  excludedSections: excludedSections,
                ),
        ],
      ),
    );
  }

  TableRow _formRow3(
    String label1,
    String value1,
    String label2,
    String value2,
    String label3,
    String value3,
  ) {
    return TableRow(
      children: [
        _formLabel(label1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(value1),
        ),
        _formLabel(label2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(value2),
        ),
        _formLabel(label3),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(value3),
        ),
      ],
    );
  }

  Widget _formLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 10),
      child: Text(
        "$label:",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  int calculateAge(String dobString) {
    // Parse the string into a DateTime object
    final dob = DateTime.parse(dobString);
    final today = DateTime.now();
    int age = today.year - dob.year;
    // Adjust age if the current date is before the birthday this year
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  // final form =
  //
  // OwsReqForm.fromJson({
  //   'ITS': '30445123',
  //   'reqByITS': '30445124',
  //   'reqByName': 'Ali Khan',
  //   'city': 'Karachi',
  //   'institution': 'NED University of Engineering & Technology',
  //   'class_degree': 'BS Computer Science',
  //   'fieldOfStudy': 'Engineering',
  //   'subject_course': 'Software Engineering',
  //   'yearOfStart': 2021,
  //   'grade': 'A+',
  //   'email': 'student@example.com',
  //   'contactNo': '+92-300-1234567',
  //   'whatsappNo': '+92-300-1234567',
  //   'purpose': 'Tuition Fees Assistance',
  //   'fundAsking': 50000.00,
  //   'classification': 'Merit Based',
  //   'organization': 'DAI Karachi',
  //   'description': 'Seeking assistance due to financial constraints.',
  //   'currentStatus': 'Enrolled - Final Year',
  //   'created_by': 'admin',
  //   'updated_by': 'admin',
  //   'created_at': DateTime.now().toIso8601String(),
  //   'updated_at': DateTime.now().toIso8601String(),
  //   'mohalla': 'Hyderi',
  //   'studentName': 'Ali Khan',
  //   'student_cnic': '42101-1234567-1',
  //   'gender': 'Male',
  // });

  Widget educationInfoSection(RequestFormModel form) {
    final List<MapEntry<String, String?>> entries = [
      MapEntry("City", form.city),
      MapEntry("Institution", form.institution),
      MapEntry("Class / Degree", form.classDegree),
      MapEntry("Field of Study", form.fieldOfStudy),
      MapEntry("Subject / Course", form.subjectCourse),
      MapEntry("Year of Start", form.yearOfStart.toString()),
      MapEntry("Grade / GPA", form.grade),
      MapEntry("Email", form.email),
      MapEntry("Contact No", form.contactNo),
      MapEntry("WhatsApp No", form.whatsappNo),
      MapEntry("Student CNIC", form.cnic),
      MapEntry("Gender", form.gender),
      MapEntry("Purpose of Application", form.purpose),
      MapEntry("Amount Requested", "PKR ${form.fundAsking}"),
      MapEntry("Classification", form.classification),
      MapEntry("Organization (if any)", form.organization),
      MapEntry("Additional Description", form.description),
      MapEntry("Current Status", form.currentStatus),
      MapEntry("Mohalla", form.mohalla),
      MapEntry("Requested By ITS", form.reqByITS),
      MapEntry("Requested By Name", form.reqByName),
      MapEntry("Student Name", form.studentFullName),
      // MapEntry("Created By", form.createdBy),
      // MapEntry("Updated By", form.updatedBy),
      // MapEntry("Created At", form.cr.toString()),
      // MapEntry("Updated At", form.updatedAt.toString()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const Text(
          "STUDENT INTENT",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const Divider(),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: entries.map((entry) {
            return SizedBox(
              width: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // const Icon(Icons.arrow_forward,
                  //     size: 16, color: Colors.brown),
                  // const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${entry.key}: ",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        entry.value?.isNotEmpty == true ? entry.value! : 'N/A',
                        style: const TextStyle(color: Colors.black87),
                      )
                    ],
                  ),
                  // Expanded(
                  //   child: Text.rich(
                  //     TextSpan(
                  //       children: [
                  //         TextSpan(
                  //           text: "${entry.key}: ",
                  //           style: const TextStyle(
                  //             fontWeight: FontWeight.w600,
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //         TextSpan(
                  //           text: entry.value?.isNotEmpty == true
                  //               ? entry.value!
                  //               : 'N/A',
                  //           style: const TextStyle(color: Colors.black87),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildParentSection({
    required String title,
    required Parent parent,
  }) {
    final entries = <MapEntry<String, String>>[
      MapEntry("Full Name", parent.fullName ?? ''),
      MapEntry("ITS", parent.itsId.toString()),
      MapEntry("Age", "${parent.age} years"),
      MapEntry("Contact", parent.mobileNo!),
      MapEntry("Email", parent.email!),
      MapEntry("Tanzeem", parent.tanzeem!),
      MapEntry("CNIC", requestForm!.fatherCnic),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.brown.shade100,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown.shade200),
            color: const Color(0xfffff7ec),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top: Image + Name/ITS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      parent.imageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(parent.fullName!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("ITS ID: ${parent.itsId}",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Bottom: Grid-style fields (3 per row)
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: entries.map((e) {
                  return SizedBox(
                    width:
                        (MediaQueryData.fromView(WidgetsBinding.instance.window)
                                    .size
                                    .width -
                                80) /
                            3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${e.key}: ",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        Expanded(
                            child: Text(
                          e.value,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.visible,
                        )),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGrid(List fields) {
    List<Widget> rows = [];

    for (int i = 0; i < fields.length; i += 3) {
      final rowItems = fields.skip(i).take(3).toList();

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (index) {
            if (index >= rowItems.length) {
              return const Expanded(child: SizedBox()); // Empty placeholder
            }
            final f = rowItems[index];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.help_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f['question'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f['answer']?.toString() ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );

      rows.add(const SizedBox(height: 12)); // vertical spacing between rows
    }

    return Column(children: rows);
  }

  Widget buildContent(Map<String, dynamic> data) {
    final sections = data['sections'] as List<dynamic>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'SECTION D: APPLICATION DATA',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ...sections.map<Widget>((sectionData) {
          final section = sectionData as Map<String, dynamic>;
          final title = section['section'];

          // Skip sections you want to ignore
          if (title == "Intent" ||
              title == "Documents Upload" ||
              title == 'Work Information') {
            if (title == 'Work Information') {
              excludedSections.add(section);
            }
            return const SizedBox.shrink();
          }

          final subsections = section['subsections'] as List<dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              ...subsections.map<Widget>((sub) {
                final Map<String, dynamic> subMap = sub;
                final fields = subMap['fields'] as List<dynamic>?;
                final entries = subMap['entries'] as List<dynamic>?;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //height: 50,
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        //decoration: BoxDecoration(color: Colors.green),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Text(
                              subMap['subsection'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                      if (fields != null && fields.isNotEmpty)
                        buildGrid(fields),
                      if (entries != null && entries.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Table(
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              // Table Header - only once
                              TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade200),
                                children: (entries.first['fields'] as List)
                                    .map<Widget>((f) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      f['question'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }).toList(),
                              ),
                              // Data Rows
                              ...entries.map<TableRow>((entry) {
                                final fields = entry['fields'] as List;
                                return TableRow(
                                  children: fields.map<Widget>((f) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                          f['answer']?.toString() ?? 'N/A'),
                                    );
                                  }).toList(),
                                );
                              }),
                            ],
                          ),
                        )
                    ],
                  ),
                );
              }),
            ],
          );
        })
      ]),
    );
  }
}

class SingleOccupationCard extends StatelessWidget {
  final List<Map<String, dynamic>> excludedSections;
  final String subsectionTitle;

  const SingleOccupationCard({
    super.key,
    required this.excludedSections,
    required this.subsectionTitle,
  });

  List<List<dynamic>> chunkList(List<dynamic> list, int chunkSize) {
    final chunks = <List<dynamic>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
        i,
        i + chunkSize > list.length ? list.length : i + chunkSize,
      ));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final workSection = excludedSections.firstWhere(
      (sec) => sec['section'] == 'Work Information',
      orElse: () => {},
    );

    if (workSection.isEmpty || workSection['subsections'] == null) {
      return const SizedBox.shrink();
    }

    final List<dynamic> subsections = workSection['subsections'];
    final targetSubsection = subsections.firstWhere(
      (s) => s['subsection'] == subsectionTitle,
      orElse: () => null,
    );

    if (targetSubsection == null) {
      return const SizedBox.shrink();
    }

    final entries = targetSubsection['entries'] as List?;
    if (entries == null || entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final fields = entries.first['fields'] as List;
    final fieldChunks = chunkList(fields, 4);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subsectionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          ...fieldChunks.map((chunk) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: chunk.map<Widget>((f) {
                return Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.work_outline,
                            size: 16, color: Colors.brown),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f['question'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                f['answer']?.toString().trim().isNotEmpty ==
                                        true
                                    ? f['answer']
                                    : 'N/A',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          })
        ],
      ),
    );
  }
}
