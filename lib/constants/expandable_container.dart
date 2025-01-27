import 'package:flutter/material.dart';

class ExpandableEducation extends StatefulWidget {
  final String title;
  final List<Widget> subEducation;

  const ExpandableEducation({super.key, required this.title, required this.subEducation});

  @override
  ExpandableEducationState createState() => ExpandableEducationState();
}

class ExpandableEducationState extends State<ExpandableEducation>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
        color: Color(0xffffead1),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _controller.forward(); // Start animation
                } else {
                  _controller.reverse(); // Reverse animation
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          Divider(),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.subEducation
                  .asMap()
                  .entries
                  .map((entry) => SlideTransition(
                position: Tween<Offset>(
                    begin: Offset(0, 1), end: Offset(0, 0))
                    .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      entry.key * 0.1, // Stagger animations
                      1.0,
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8.0),
                  child: entry.value,
                ),
              ))
                  .toList(),
            )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}