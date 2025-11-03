import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/src/widgets/apple_logo_painter.dart';
//import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rjfruits/res/components/colors.dart';

/// The scale based on the height of the button
const _appleIconSizeScale = 28 / 44;

/// A `Continue with Apple` button according to the Apple Guidelines.
///
/// https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/
class ContinueWithAppleButton extends StatelessWidget {
  const ContinueWithAppleButton({
    super.key,
    required this.onPressed,
    this.text = 'Continue with Apple',
    this.height = 48, //44,
    this.style = ContinueWithAppleButtonStyle.black,
    this.borderRadius = const BorderRadius.all(
        Radius.circular(8.0)), //const BorderRadius.all(Radius.circular(8.0)),
    this.iconAlignment = AppleIconAlignment.center,
  });

  /// The callback that is be called when the button is pressed.
  final VoidCallback onPressed;

  /// The text to display next to the Apple logo.
  ///
  /// Defaults to `Sign in with Apple`.
  final String text;

  /// The height of the button.
  ///
  /// This defaults to `44` according to Apple's guidelines.
  final double height;

  /// The style of the button.
  ///
  /// Supported options are in line with Apple's guidelines.
  ///
  /// This defaults to [ContinueWithAppleButtonStyle.black].
  final ContinueWithAppleButtonStyle style;

  /// The border radius of the button.
  ///
  /// Defaults to `8` pixels.
  final BorderRadius borderRadius;

  /// The alignment of the Apple logo inside the button.
  ///
  /// This defaults to [IconAlignment.center].
  final AppleIconAlignment iconAlignment;

  /// Returns the background color of the button based on the current [style].
  Color get _backgroundColor {
    switch (style) {
      case ContinueWithAppleButtonStyle.black:
        return Colors.black;
      case ContinueWithAppleButtonStyle.white:
        return Colors.white;
      case ContinueWithAppleButtonStyle.whiteOutlined:
        return Colors.transparent;
    }
  }

  /// Returns the contrast color to the [_backgroundColor] derived from the current [style].
  ///
  /// This is used for the text and logo color.
  Color get _contrastColor {
    switch (style) {
      case ContinueWithAppleButtonStyle.black:
        return Colors.white;
      case ContinueWithAppleButtonStyle.white:
      case ContinueWithAppleButtonStyle.whiteOutlined:
        return Colors.black;
    }
  }

  /// The decoration which should be applied to the inner container inside the button
  ///
  /// This allows to customize the border of the button
  Decoration? get _decoration {
    switch (style) {
      case ContinueWithAppleButtonStyle.black:
      case ContinueWithAppleButtonStyle.white:
        return null;

      case ContinueWithAppleButtonStyle.whiteOutlined:
        return BoxDecoration(
          border: Border.all(width: 1, color: _contrastColor),
          borderRadius: borderRadius,
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // per Apple's guidelines
    final fontSize = height * 0.43;

    final textWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.getFont("Poppins",
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _contrastColor,
          )),
      /*TextStyle(
        inherit: false,
        fontSize: 17, //fontSize,
        fontWeight: FontWeight.w500,
        color: _contrastColor,
        // defaults styles aligned with https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/cupertino/text_theme.dart#L16
        fontFamily: "Poppins", //'.SF Pro Text',
        //letterSpacing: -0.41,
      ),*/
    );

    final appleIcon = Container(
      width: _appleIconSizeScale * height,
      height: _appleIconSizeScale * height + 2,
      padding: EdgeInsets.only(
        // Properly aligns the Apple icon with the text of the button
        bottom: (4 / 44) * height,
      ),
      child: Center(
        child: SizedBox(
          width: fontSize * (25 / 31),
          height: fontSize,
          child: CustomPaint(
            painter: AppleLogoPainter(
              color: _contrastColor,
            ),
          ),
        ),
      ),
    );

    var children = <Widget>[];

    switch (iconAlignment) {
      case AppleIconAlignment.center:
        children = [
          appleIcon,
          Flexible(
            child: textWidget,
          ),
        ];
        break;
      case AppleIconAlignment.left:
        children = [
          appleIcon,
          Expanded(
            child: textWidget,
          ),
          SizedBox(
            width: _appleIconSizeScale * height,
          ),
        ];
        break;
    }

    return SizedBox(
      height: height,
      child: SizedBox.expand(
        child: CupertinoButton(
          borderRadius: borderRadius,
          padding: EdgeInsets.zero,
          color: _backgroundColor,
          onPressed: onPressed,
          child: Container(
            decoration: _decoration,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// The style of the button according to Apple's documentation.
///
/// https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/
enum ContinueWithAppleButtonStyle {
  /// A black button with white text and white icon
  ///
  /// ![Black Button](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/black_button.png)
  black,

  /// A white button with black text and black icon
  ///
  /// ![White Button](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/white_button.png)
  white,

  /// A white button which has a black outline
  ///
  /// ![White Outline Button](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/white_outlined_button.png)
  whiteOutlined

  /// This controls the alignment of the Apple Logo on the [SignInWithAppleButton]
}

enum AppleIconAlignment {
  /// The icon will be centered together with the text
  ///
  /// ![Center Icon Alignment](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/center_aligned_icon.png)
  center,

  /// The icon will be on the left side, while the text will be centered accordingly
  ///
  /// ![Left Icon Alignment](https://raw.githubusercontent.com/aboutyou/dart_packages/master/packages/sign_in_with_apple/test/sign_in_with_apple_button/goldens/left_aligned_icon.png)
  left,
}
