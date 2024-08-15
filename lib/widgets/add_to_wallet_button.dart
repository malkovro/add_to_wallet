import 'dart:async';

import 'package:add_to_wallet/add_to_wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class AddToWalletButton extends StatefulWidget {
  static const viewType = 'PKAddPassButton';

  final List<int>? pkPass;
  final String? issuerData;
  final String? signature;
  final double width;
  final double height;
  final Widget? unsupportedPlatformChild;
  final FutureOr<void> Function()? onPressed;
  final String _id = Uuid().v4();

  AddToWalletButton(
      {Key? key,
      this.pkPass,
      this.issuerData,
      this.signature,
      required this.width,
      required this.height,
      this.onPressed,
      this.unsupportedPlatformChild})
      : super(key: key) {
    assert(pkPass != null || (issuerData != null && signature != null));
  }

  @override
  _AddToWalletButtonState createState() => _AddToWalletButtonState();
}

class _AddToWalletButtonState extends State<AddToWalletButton> {
  get uiKitCreationParams => {
        'width': widget.width,
        'height': widget.height,
        'pass': widget.pkPass,
        'issuerData': widget.issuerData,
        'signature': widget.signature,
        'key': widget._id,
      };

  @override
  void initState() {
    super.initState();
    AddToWallet().addHandler(widget._id, (_) => widget.onPressed?.call());
  }

  void dispose() {
    AddToWallet().removeHandler(widget._id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: platformWidget(context),
    );
  }

  Widget platformWidget(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AddToWalletButton.viewType,
          layoutDirection: Directionality.of(context),
          creationParams: uiKitCreationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        if (widget.unsupportedPlatformChild == null)
          throw UnsupportedError('Unsupported platform view');
        return widget.unsupportedPlatformChild!;
    }
  }
}
