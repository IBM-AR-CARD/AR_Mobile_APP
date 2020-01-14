import 'package:flutter/material.dart';

class ProfileTextEditor extends StatelessWidget {
  static final int DROPDOWN = 0;
  static final int TEXTBOX = 1;
  final Widget _title;
  final int _type;
  final TextEditingController _controller;
  List<String> _dropContent;
  String _hint;
  String _text;
  Function _dropOnChange;
  String _currentSelect;
  ProfileTextEditor(this._title, this._type, this._controller,
      {String text,
      String hint,
      List<String> dropContent,
      Function dropOnChange,
      String currentSelect}) {
    _hint = hint;
    _text = text;
    _dropContent = dropContent;
    _dropOnChange = dropOnChange;
    _currentSelect = currentSelect;
  }
  Widget build(context) {
    Widget box;
    if (_type == TEXTBOX) {
      box = new Padding(
        padding: EdgeInsets.only(top: 30),
        child: new TextField(
          style: new TextStyle(color: Colors.white),
          maxLines: 4,
          controller: this._controller,
          decoration: new InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 61, 63, 83),
              hintText: _hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
              ),
              labelStyle: new TextStyle(color: const Color.fromARGB(255, 0, 196, 225))),
        ),
      );
      if (_text != null) _controller.text = _text;
    } else if (_type == DROPDOWN) {
      box = Padding(
          padding: EdgeInsets.only(top: 30),
          child:ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft:  const  Radius.circular(4.0),
                  topRight: const  Radius.circular(4.0))
                    )
                ),
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 61, 63, 83),
              border: Border(
                bottom: BorderSide(
                  color: Colors.black
                )
              ),
            ),
            height:50,
            width: MediaQuery.of(context).size.width,
            child: new Theme(
              data: new ThemeData(
                canvasColor: Color.fromARGB(255, 41, 43, 66),
                  primaryColor: Colors.black,
                  accentColor: Colors.black,
                  hintColor: Colors.black,
              ),
              child:Listener(
                onPointerDown: (_) => FocusScope.of(context).unfocus(),
                child:DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentSelect,
                  isExpanded: true,
                  items: _dropContent.map((String val) {
                    return new DropdownMenuItem<String>(
                      value: val,
                      child:Padding(
                        padding: EdgeInsets.only(left:15),
                        child: new Text(
                          val,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    );
                  }).toList(),
                  onChanged: _dropOnChange,
                ),
                ),
              ),
            ),
          ),
          ));
    }
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[_title, box],
    );
  }
}
