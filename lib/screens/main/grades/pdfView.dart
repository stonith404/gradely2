import 'package:flutter/material.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

// ignore: must_be_immutable
class PdfViewPage extends StatelessWidget {
  var attachment;
  var attachmentName;
  PdfViewPage(this.attachment, this.attachmentName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text(attachmentName, style: appBarTextTheme),
        shape: defaultRoundedCorners(),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        child: FutureBuilder(
          future: storage.getFileView(
            fileId: attachment,
          ),
          builder: (context, snapshot) {
            return snapshot.hasData && snapshot.data != null
                ? (() {
                    final pdfController = PdfController(
                        document: PdfDocument.openData(snapshot.data.data));
                    return Column(
                      children: [
                        Text(""),
                        Expanded(
                          child: PdfView(
                            controller: pdfController,
                          ),
                        ),
                      ],
                    );
                  }())
                : GradelyLoadingIndicator();
          },
        ),
      ),
    );
  }
}
