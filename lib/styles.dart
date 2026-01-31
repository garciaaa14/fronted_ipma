import 'package:flutter/material.dart';

class CustomColor {
  static const Color mainBackground = Color(0xFFF1FFE4);
  static const Color group = Color(0xFFA4A2A2);
  static const Color textSubTitle = Color(0xC8369563);
  static const Color textSubSubTitle = Color(0xC8369563);
  static const Color textActive = Color(0xC8369563);
  static const Color textInactive = Colors.black;
  static const Color boxSelected = Color(0xFFCDDC39);
  static const Color boxNotSelected = Color(0xDEDEDEE5);
  static const Color scrollableList = Color(0xDEDEDEE5);
  static const Color boxUncheckedDisabled = Color(0xFFA4A2A2);
  static const Color boxCheckedDisabled = Color(0xFFB7CDB8);
  static const Color textBoxSelected = Color(0xFFCDDC39);
  static const Color textSelected = Color(0xFFCDDC39);
  static const Color textSelectedHandler = Color(0xFFCDDC39);
  static const Color switchActiveTrackColor = Color(0xFFB7CDB8);
  static const Color switchActiveColor = Color(0xC8369563);
  static const Color borders = Colors.black26;
  static const Color notificationsBackground = Colors.black;
  static const Color notificationsText = Colors.white;
  static const Color buttonColor = Color(0xFF4CAF50);
}

class CustomTextStyle {
  static const TextStyle textSubTitle = TextStyle(
    height: 1.5,
    fontWeight: FontWeight.bold,
    color: CustomColor.textSubTitle,
    fontSize: 16,
  );
  static const TextStyle textSubSubTitle = TextStyle(
    color: CustomColor.textSubSubTitle,
    fontSize: 16,
  );
  static const TextStyle textSmallerSubTitle = TextStyle(
    color: CustomColor.textSubSubTitle,
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );
}

class CustomButtonStyle {
  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: CustomColor.buttonColor,
    minimumSize: const Size(double.infinity, 40),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.height = 40,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: CustomColor.mainBackground,
      titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
      title: title,
    );
  }
}

class CustomContainerMain extends StatelessWidget {
  final Widget child;

  const CustomContainerMain({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(shape: BoxShape.rectangle, color: CustomColor.mainBackground),
      child: child,
    );
  }
}

class CustomContainerGroup extends StatelessWidget {
  final Widget child;

  const CustomContainerGroup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: CustomColor.borders,
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2), // changes position of shadow
            ),
          ],
          shape: BoxShape.rectangle,
          border: Border.all(color: CustomColor.borders),
          color: CustomColor.group,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: child,
    );
  }
}
