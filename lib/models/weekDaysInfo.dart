class WeekDaysInfo {
  String _day = '';
  bool _isOpen24 = false;
  bool _isOpened = false;
  String _openHour = '_ _ : _ _';
  String _closeHour = '_ _ : _ _';

  WeekDaysInfo(this._day);

  void setDay(day) {
    this._day = day;
  }

  String getDay() {
    return _day;
  }

  void setIsOpen24(isOpen24) {
    this._isOpen24 = isOpen24;
  }

  bool getIsOpen24() {
    return _isOpen24;
  }

  void setIsOpened(isOpened) {
    this._isOpened = isOpened;
  }

  bool getIsOpened() {
    return _isOpened;
  }

  void setOpenHour(openHour) {
    this._openHour = openHour;
  }

  String getOpenHour() {
    return _openHour;
  }

  void setCloseHour(closeHour) {
    this._closeHour = closeHour;
  }

  String getCloseHour() {
    return _closeHour;
  }

  String calculateOpenHourAsString() {
    if (_isOpened == true) {
      if (_isOpen24 == true) {
        return '24';
      } else {
        return _openHour == '_ _ : _ _' ? 'closed' : _openHour;
      }
    } else {
      return 'closed';
    }
  }

  String calculateCloseHourAsString() {
    if (_isOpened == true) {
      if (_isOpen24 == true) {
        return '24';
      } else {
        return _closeHour == '_ _ : _ _' ? 'closed' : _closeHour;
      }
    } else {
      return 'closed';
    }
  }
}
