Object.extend(Number.prototype, {
  seconds: function() {
    return this * 1000;
  },
  
  minutes: function() {
    return this * (60).seconds();
  },
  
  hours: function() {
    return this * (60).minutes();
  },
  
  days: function() {
    return this * (24).hours();
  },
  
  weeks: function(args) {
    return this * (7).days();
  },
  
  fortnights: function() {
    return this * (2).weeks();
  },
  
  months: function() {
    return this * (30).days();
  },
  
  years: function() {
    return parseInt(this * (365.25).days())
  },
  
  since: function(time) {
    time = time || new Date();
    if (time instanceof Date) time = time.getTime();
    return this + time;
  },
  
  ago: function(time) {
    time = time || new Date();
    if (time instanceof Date) time = time.getTime();
    return time - this;
  },
  
  toDate: function() {
    var date = new Date();
    date.setTime(this);
    return date;
  }
});

Object.extend(Number.prototype, {
  second:    Number.prototype.seconds,
  minute:    Number.prototype.minutes,
  hour:      Number.prototype.hours,
  day:       Number.prototype.days,
  week:      Number.prototype.weeks,
  fortnight: Number.prototype.fortnights,
  month:     Number.prototype.months,
  year:      Number.prototype.years,
  from_now:  Number.prototype.since,
  fromNow:   Number.prototype.since,
  until:     Number.prototype.ago
});