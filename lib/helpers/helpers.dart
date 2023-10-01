import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class Helpers {
  late ProgressDialog progressDialog;

  showProgress(BuildContext context, String message, bool isDismissible) async {
    progressDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: isDismissible);
    progressDialog.style(
        message: message,
        borderRadius: 10.0,
        backgroundColor: Colors.blue,
        progressWidget: Container(
            padding: const EdgeInsets.all(8.0),
            child: const CircularProgressIndicator(
              backgroundColor: Colors.white,
            )),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: const TextStyle(
            color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));
    await progressDialog.show();
  }

  hideProgress() async {
    await progressDialog.hide();
  }
}

Helpers helpers = Helpers();
