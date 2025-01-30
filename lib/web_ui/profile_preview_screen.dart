import 'package:flutter/material.dart';
import 'package:ows/controller/request_form_controller.dart';
import 'package:ows/model/member_model.dart';
import 'package:ows/constants/constants.dart';
import 'package:ows/constants/expandable_container.dart';
import 'package:ows/web_ui/request_form.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../model/family_model.dart';

class ProfilePreview extends StatelessWidget {
  final UserProfile member;
  final Family family;
  ProfilePreview({super.key, required this.member, required this.family});

  late final List<Widget> futureSubEducation = [
    subEducation("Dunyawi", "Future Education Plan,", "No Data Available"),
    subEducation("Dunyawi", "Future Education Plan,", "No Data Available"),
    subEducation("Dunyawi", "Future Education Plan,", "No Data Available"),
  ];



  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define the minimum width for your content
    const double minWidth = 1280;

    // Determine whether the screen is narrower than your minimum width
    final bool isScreenNarrow = screenWidth < minWidth;

    // Wrap your content in a SingleChildScrollView if the screen is too narrow
    Widget content = isScreenNarrow
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minWidth, child: buildContent(context)),
          )
        : buildContent(context);

    return SelectionArea(
      child: Scaffold(
        backgroundColor: Color(0xfffff7ec),
        body: SingleChildScrollView(
          child: SizedBox(
            child: content,
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        spacing: 10,
        children: [
          headerSection(context),
          headerProfile(context),
          Divider(),
          otherItems(context),
        ],
      ),
    );
  }

  Widget headerSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Constants().heading('Profile Preview'),
        Row(
          spacing: 16,
          children: [
            SizedBox(
              width: 120,
              height: 35,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008759),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => RequestForm(member: member));
                  },
                  child: Text(
                    "Request",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            SizedBox(
              height: 35,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.transparent; // No hover effect
                      }
                      return Colors.transparent; // Default color
                    },
                  ),
                  overlayColor: WidgetStateProperty.all(
                      Colors.transparent), // No ripple effect
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: const Color(0xFF008759),
                        width: 2, // Green border
                      ),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(0), // Flat button
                ),
                onPressed: () async {
                  Constants().Logout();
                },
                child: Text(
                  "Logout",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget headerProfile(BuildContext context) {
    return Row(
      children: [
        // Container(
        //   width: 120,
        //     height: 170,
        //     child: Image.asset('assets/img.png',fit: BoxFit.contain,)
        // ),
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                'http://localhost:3001/fetch-image?url=${Uri.encodeComponent(member.imageUrl!)}',
                width: 140,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.fullName!),
                  Text(" | "),
                  Text('${member.itsId}')
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                spacing: 10,
                children: [
                  Row(
                    spacing: 5,
                    children: [Icon(Icons.email), Text(member.email!)],
                  ),
                  Row(
                    spacing: 5,
                    children: [Icon(Icons.phone), Text(member.mobileNo!)],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.calendar_month_rounded),
                      Text(member.dob!)
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                spacing: 12,
                children: [
                  profileBox('Jamaat:', member.tanzeem!, context),
                  profileBox(
                      'Hifz Sanad:', (member.hifzSanad == null || member.hifzSanad!.isEmpty) ? '-' : member.hifzSanad.toString(), context),
                  profileBox(
                      'Current:', member.currentClass.toString(), context),
                  profileBox(
                      'Marhala Status:', (member.status == 1) ? 'Completed' : 'Ongoing', context),
                  profileBox('Ambition', member.ambitionId.toString(), context),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text("Your profile is 100% Completed!",
                    softWrap: false, overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                Text("HOF ITS: ${member.hofId}",
                    softWrap: false, overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold),),
                Text("Idara: ${member.idara}",
                    softWrap: false, overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Organization: ${member.organization}",
                    softWrap: false, overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold) )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget otherItems(BuildContext context) {
    List<String> marhalas = [
      "Marhala 7",
      "Marhala 6",
      "Marhala 5",
      "Marhala 4",
      "Marhala 4",
      "Marhala 4",
      "Marhala 4"
    ];
    List<Widget> customContents = [
      Text(
        "Post Graduation",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "Graduation",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "11th to 12th",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "9th to 10th",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "5th to 8th",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "1st to 4th",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        "Pre Primary",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ];

    final groupedEducation = groupEducationByMarhala(member.education ?? []);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 20,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              width: Constants().responsiveWidth(context, 0.3),
              decoration: BoxDecoration(
                  color: Color(0xffffead1),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants().subHeading("Education Journey"),
                  Divider(),
                  Container(
                    padding: EdgeInsets.only(right: 40),
                    child: FixedTimeline.tileBuilder(
                      theme: TimelineThemeData(
                        indicatorTheme: IndicatorThemeData(
                            color: Constants().green, size: 20),
                        direction: Axis.vertical,
                        connectorTheme: ConnectorThemeData(
                          space: 30.0,
                          thickness: 1.0,
                          color: Colors.brown,
                        ),
                      ),
                      builder: TimelineTileBuilder.connectedFromStyle(
                        contentsAlign: ContentsAlign.reverse,
                        oppositeContentsBuilder: (context, index) {
                          // Returning custom content for each index
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customContents[index],
                                Text(
                                  "Completed",
                                  style: TextStyle(
                                      color: Constants().green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ), // Custom content changes for each item
                          );
                        },
                        contentsBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              marhalas[index],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ), // Display marhala from bottom to top
                          );
                        },
                        connectorStyleBuilder: (context, index) =>
                            ConnectorStyle.solidLine,
                        indicatorStyleBuilder: (context, index) =>
                            IndicatorStyle.outlined,
                        itemCount: marhalas.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              width: Constants().responsiveWidth(context, 0.3),
              decoration: BoxDecoration(
                  color: Color(0xffffead1),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants().subHeading("Family"),
                  Divider(),
                  familyContainer(context, family),
                ],
              ),
            ),
          ],
        ),

        Expanded(
          child: Column(
            spacing: 20,
            children: [
              ExpandableEducation(
                title: "Future Education",
                subEducation: futureSubEducation,
              ),
              ...groupedEducation.entries.map((entry) {
                return ExpandableEducation(
                  title: "Marhala ${entry.key}",
                  subEducation: entry.value.map((edu) => educationDetails(edu,edu.imaniOtherSchool ?? 0)).toList(),
                );
              }),
            ],
          ),
        )
      ],
    );
  }

  Widget educationDetails(Education education,int type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Color(0xfffff7ec),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: type == 1 ? Constants().blue : Constants().green,
                ),
                child: Text(
                  type == 1 ? 'Deeni' : 'Dunyawi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text("Institution: ${education.institute ?? '-'}"),
              Text("Course: ${education.subject ?? '-'}"),
              Text("Standard: ${education.standard ?? '-'}"),
              Text("Status: ${education.status ?? '-'}"),
              Text("Duration: ${education.duration ?? '-'} months"),
              Text("Scholarship: ${education.scholarship ?? '-'}"),
              Text("Qarzan: ${education.qardan ?? '-'}"),

            ],
          ),
        )
      ],
    );
  }

  Widget familyContainer(BuildContext context, Family family) {
    // Combine family members into a single list with type
    List<Map<String, dynamic>> familyMembers = [
      if (family.father != null)
        {
          'type': 'Father',
          'member': family.father,
        },
      if (family.mother != null)
        {
          'type': 'Mother',
          'member': family.mother,
        },
      {
        'type': 'Child',
        'member': family,
      },
    ];

    return Wrap(
      spacing: 20, // Space between items
      runSpacing: 20, // Space between rows
      children: familyMembers.map((item) {
        final String type = item['type']
            as String; // Type of member (e.g., Father, Mother, Child)
        final dynamic member =
            item['member']; // Member object (Parent or Child)

        // Safeguard for null or invalid member data
        final String imageUrl =
            (member is Parent ? member.image : (member as Family).image) ??
                ''; // Use imageUrl if available
        final String fullName =
            (member is Parent ? member.fullName : (member as Family).fullName) ??
                ''; // Fallback for fullName
        final String itsId =
            (member is Parent ? member.fullName: (member as Family).its)
                .toString(); // ITS ID fallback

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                'http://localhost:3001/fetch-image?url=${Uri.encodeComponent(imageUrl)}',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            // Member Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // ITS Number and Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ITS: $itsId'),
                        Row(
                          children: const [
                            Icon(Icons.refresh, size: 16),
                            Text("100%"),
                          ],
                        ),
                      ],
                    ),
                    // Relationship Type
                    Text(type),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget marhalaEducation(String type, String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Color(0xfffff7ec),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color:
                        type == 'Deeni' ? Constants().blue : Constants().green),
                child: Text(
                  type,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text("Status: ${member.education![0].status}"),
              Text("Instition: ${member.education![0].institute}"),
              Text("Course: ${member.education![0].subject}"),
              Text("Qarzan: ${member.education![0].qardan}"),
              Text("Scholarship: ${member.education![0].scholarship}"),
            ],
          ),
        )
      ],
    );
  }

  Widget subEducation(String type, String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Color(0xfffff7ec),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Dunyawi"), Text("No Data Available")],
              ),
              Text(
                "Future Education Plan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget education(String title, List<Widget> subEducation) {
    return Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
            color: Color(0xffffead1),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [Constants().heading(title), Divider(), ...subEducation],
        ));
  }

  Widget profileBox(String title, String value, BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(10),
      width: Constants().responsiveWidth(context, 0.12),
      height: 100,
      decoration: BoxDecoration(
          color: Color(0xffffead1),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          Text(title,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  color: Constants().green, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Map<int, List<Education>> groupEducationByMarhala(
      List<Education> educationList) {
    Map<int, List<Education>> groupedEducation = {};
    for (var education in educationList) {
      groupedEducation
          .putIfAbsent(education.marhalaId!, () => [])
          .add(education);
    }
    return groupedEducation;
  }
}
