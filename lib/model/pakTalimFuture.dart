class FutureFormData {
  final String itsId; // int (as string, 8 digits)
  final String isHafiz; // int (0 or 1)
  final String isHifzNiyat; // int (0 or 1)
  final String currentHifzEnrolled; // string
  final String niyatHifzEnrolled; // string
  final String nextSanad; // int (as string)
  final String isQuranTilawat; // int (0 or 1)
  final String sehatEraab; // int (0 or 1)
  final String sehatHuroof; // int (0 or 1)
  final String isTilawatNiyat; // int (0 or 1)
  final String tilawatPreferredDays; // string
  final String tilawatPreferredTimings; // string
  final String attendedCounselling; // int (0 or 1)
  final String comments; // string
  final String willAsbaaq; // int (0 or 1)
  final String willKhidmat; // int (0 or 1)
  final String khidmat; // string
  final List<StudyDetail> details;

  FutureFormData({
    this.itsId = '',
    this.isHafiz = '0',
    this.isHifzNiyat = '0',
    this.currentHifzEnrolled = 'None',
    this.niyatHifzEnrolled = 'None',
    this.nextSanad = '',
    this.isQuranTilawat = '0',
    this.sehatEraab = '0',
    this.sehatHuroof = '0',
    this.isTilawatNiyat = '0',
    this.tilawatPreferredDays = '',
    this.tilawatPreferredTimings = '',
    this.attendedCounselling = '0',
    this.comments = '',
    this.willAsbaaq = '0',
    this.willKhidmat = '0',
    this.khidmat = 'None',
    this.details = const [],
  });

  Map<String, String> toFormData() {
    final Map<String, String> formMap = {
      'its_id': itsId,
      'is_hafiz': isHafiz,
      'is_hifz_niyat': isHifzNiyat,
      'current_hifz_enrolled': currentHifzEnrolled,
      'niyat_hifz_enrolled': niyatHifzEnrolled,
      'next_sanad': nextSanad,
      'is_quran_tilawat': isQuranTilawat,
      'sehat_eraab': sehatEraab,
      'sehat_huroof': sehatHuroof,
      'is_tilawat_niyat': isTilawatNiyat,
      'tilawat_preferred_days': tilawatPreferredDays,
      'tilawat_preferred_timings': tilawatPreferredTimings,
      'attended_counselling': attendedCounselling,
      'comments': comments,
      'will_asbaaq': willAsbaaq,
      'will_khidmat': willKhidmat,
      'khidmat': khidmat,
    };

    for (int i = 0; i < details.length; i++) {
      formMap.addAll(details[i].toMap(i));
    }

    return formMap;
  }
}

class StudyDetail {
  final String studyLocation; // string
  final String cityId; // int as string
  final String institute; // int as string
  final String course; // int as string
  final String countryId; // int as string
  final String relativeAbroad; // int (0 or 1)
  final String relationship; // string
  final String relationshipIts; // int (as string, 8 digits)
  final String stayTogether; // int (0 or 1)

  StudyDetail({
    this.studyLocation = '',
    this.cityId = '',
    this.institute = '',
    this.course = '',
    this.countryId = '',
    this.relativeAbroad = '0',
    this.relationship = '',
    this.relationshipIts = '',
    this.stayTogether = '0',
  });

  Map<String, String> toMap(int index) {
    return {
      'details[$index][study_location]': studyLocation,
      'details[$index][city_id]': cityId,
      'details[$index][institute]': institute,
      'details[$index][course]': course,
      'details[$index][country_id]': countryId,
      'details[$index][relative_abroad]': relativeAbroad,
      'details[$index][relationship]': relationship,
      'details[$index][relationship_its]': relationshipIts,
      'details[$index][stay_together]': stayTogether,
    };
  }
}