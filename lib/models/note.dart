class Note {
  int? _id;
  String _title;
  String? _description;
  String _date;
  int _priority;

  Note(this._title, this._date, this._priority, [this._description = '']);

  Note.withId(this._id, this._title, this._date, this._priority, [this._description]);

  int? get id => _id;
  String get title => _title;
  String? get description => _description;
  String get date => _date;
  int get priority => _priority;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      _title = newTitle;
    }
  }

  set description(String? newDescription) {
    if (newDescription != null && newDescription.length <= 255) {
      _description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      _priority = newPriority;
    }
  }

  set date(String newDate) {
    _date = newDate;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;
    return map;
  }

  // Extract a Note object from a Map object
  Note.fromMapObject(Map<String, dynamic> map) :
        _id = map['id'] as int?,
        _title = map['title'] as String,
        _description = map['description'] as String?,
        _priority = map['priority'] as int,
        _date = map['date'] as String;
}

