// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get activePlansEmptyMessage =>
      'Yakininda koordinasyon baslatmak icin basit bir plan yayinla.';

  @override
  String get activePlansEmptyTitle => 'Henuz aktif plan yok';

  @override
  String activePlansLimit(int limit) {
    return 'Ayni anda en fazla $limit aktif plan acik tutabilirsin.';
  }

  @override
  String get activePlansTitle => 'Aktif planlarin';

  @override
  String get activitiesFocusSubtitle =>
      'Istekleri incelerken mevcut planini gorunur tut.';

  @override
  String get activitiesFocusTitle => 'Odaktaki plan';

  @override
  String get activitiesTitle => 'Plan olustur';

  @override
  String get activity => 'Aktivite';

  @override
  String get activityChat => 'Sohbet';

  @override
  String get activityCoffee => 'Kahve';

  @override
  String get activityCowork => 'Birlikte calisma';

  @override
  String get activityEvent => 'Etkinlik';

  @override
  String get activityGames => 'Oyun';

  @override
  String get activityIndoor => 'Kapali mekan';

  @override
  String get activityMovie => 'Film';

  @override
  String get activityOutdoor => 'Acik hava';

  @override
  String get activitySports => 'Spor';

  @override
  String get activityStatusCancelled => 'Iptal edildi';

  @override
  String get activityStatusCompleted => 'Tamamlandi';

  @override
  String get activityStatusDraft => 'Taslak';

  @override
  String get activityStatusFull => 'Dolu';

  @override
  String get activityStatusOpen => 'Acik';

  @override
  String activityDurationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get activityWalk => 'Yuruyus';

  @override
  String get analyticsAuthGuestPreviewSelected => 'Misafir onizlemesi secildi';

  @override
  String get analyticsAuthPhoneSelected => 'Telefonla giris secildi';

  @override
  String get analyticsChatMessageSent => 'Sohbet mesaji gonderildi';

  @override
  String get analyticsExploreCategorySelected => 'Kesif kategorisi secildi';

  @override
  String get analyticsExploreSurfaceSelected => 'Kesif yuzeyi secildi';

  @override
  String get analyticsJoinRequestApproved => 'Katilim istegi onaylandi';

  @override
  String get analyticsJoinRequestRejected => 'Katilim istegi reddedildi';

  @override
  String get analyticsJoinRequestSubmitted => 'Katilim istegi gonderildi';

  @override
  String get analyticsMapJoinRequestSubmitted =>
      'Haritadan katilim istegi gonderildi';

  @override
  String get analyticsMapNearbyJoinRequestSubmitted =>
      'Yakin haritadan katilim istegi gonderildi';

  @override
  String get analyticsOnboardingCompleted => 'Onboarding tamamlandi';

  @override
  String get analyticsPlanPublished => 'Plan yayinlandi';

  @override
  String get analyticsProfileUpdated => 'Profil guncellendi';

  @override
  String get analyticsSafetyReportSubmitted => 'Guvenlik bildirimi gonderildi';

  @override
  String get analyticsSafetyUserBlocked => 'Kullanici engellendi';

  @override
  String get analyticsSessionSignedOut => 'Cikis yapildi';

  @override
  String get analyticsSettingsLocationPrivacy =>
      'Yaklasik konum ayari guncellendi';

  @override
  String get analyticsSettingsNotifications => 'Bildirim ayari guncellendi';

  @override
  String get analyticsSettingsSafeMeetup =>
      'Guvenli bulusma hatirlatmasi guncellendi';

  @override
  String analyticsSummaryAuth(int count) {
    return '$count kimlik islemi';
  }

  @override
  String analyticsSummaryCoordination(int count) {
    return '$count koordinasyon islemi';
  }

  @override
  String analyticsSummarySafety(int count) {
    return '$count guvenlik islemi';
  }

  @override
  String get approveRequest => 'Onayla';

  @override
  String get authSubtitle =>
      'Yakin planlar olusturmak, baskalarina katilmak ve dusuk baskili sekilde koordine olmak icin giris yap.';

  @override
  String get authTitle => 'Basit bir planla basla';

  @override
  String get authPhoneEmpty => 'Devam etmek icin bir telefon numarasi gir.';

  @override
  String get authPhoneCodeSentMessage =>
      'Bir dogrulama kodu gonderdik. Telefonla girisi tamamlamak icin asagida gir.';

  @override
  String get authPhoneCodeSentTitle => 'Dogrulama kodu gonderildi';

  @override
  String get authCodeConfirm => 'Kodu onayla';

  @override
  String get authCodeEmpty => '6 haneli dogrulama kodunu gir.';

  @override
  String get authCodeExpired =>
      'Bu dogrulama kodunun suresi doldu. Telefonla girisi yeniden baslat.';

  @override
  String get authCodeFieldHint => '123456';

  @override
  String get authCodeFieldLabel => 'Dogrulama kodu';

  @override
  String get authCodeInvalid => 'Gonderdigimiz guncel 6 haneli kodu gir.';

  @override
  String get authCodeResend => 'Kodu tekrar gonder';

  @override
  String get authCodeResent => 'Yeni bir dogrulama kodu gonderdik.';

  @override
  String get authCodeSubmitting => 'Kod dogrulaniyor...';

  @override
  String get authCodeTooManyRequests =>
      'Cok fazla deneme yapildi. Biraz bekleyip tekrar dene.';

  @override
  String get authPhoneFailed => 'Telefonla giris su anda baslatilamadi.';

  @override
  String get authPhoneFieldHelper =>
      'Ulasilabilir bir numara kullan. +90 gibi ulke kodu eklemek dogrulamayi netlestirir.';

  @override
  String get authPhoneFieldHint => '+90 555 000 00 00';

  @override
  String get authPhoneFieldLabel => 'Telefon numarasi';

  @override
  String get authPhoneInvalid => 'Gecerli bir telefon numarasi gir.';

  @override
  String get authPhoneSubmitting => 'Telefonla giris baslatiliyor...';

  @override
  String get authPhoneUnsupported =>
      'Telefon dogrulama arayuzu bu platformda henuz tam baglanmadi.';

  @override
  String get authPhoneVerificationPending =>
      'Girisi tamamlamak icin gonderdigimiz kodu gir.';

  @override
  String get availabilityAfternoons => 'Ogleden sonralari';

  @override
  String get availabilityEvenings => 'Aksamlari';

  @override
  String get availabilityMornings => 'Sabahlari';

  @override
  String get availabilityWeekends => 'Hafta sonlari';

  @override
  String get blockUser => 'Kullaniciyi engelle';

  @override
  String chatActivityLabel(String activityId) {
    return 'Aktivite: $activityId';
  }

  @override
  String get chatComposerHint => 'Pratik bir mesaj yaz';

  @override
  String get chatEmptyMessage =>
      'Bir katilim istegi onaylandiginda konusma zamanlama ve bulusma detaylarina odaklanabilir.';

  @override
  String get chatEmptyTitle => 'Henuz onayli sohbet yok';

  @override
  String get chatHistoryEmpty => 'Henuz mesaj yok.';

  @override
  String get chatHistoryTitle => 'Son mesajlar';

  @override
  String chatParticipantsCount(int count) {
    return '$count katilimci';
  }

  @override
  String get chatPrimaryThreadEmpty =>
      'Koordinasyona baslamak icin onayli bir sohbet sec.';

  @override
  String get chatPrimaryThreadSubtitle =>
      'Ana koordinasyon sohbetin burada sabit kalir.';

  @override
  String get chatPrimaryThreadTitle => 'Ana sohbet';

  @override
  String get chatQuickRepliesHint =>
      'Plani ilerletmek icin kisa koordinasyon yanitlari kullan.';

  @override
  String get chatQuickRepliesTitle => 'Hazir yanitlar';

  @override
  String get chatSafetyBanner =>
      'Herkese acik ve kolay bulunur bir yerde bulus; tam detaylari sadece onayli sohbette paylas.';

  @override
  String get chatThreadCreatedPreview =>
      'Istek onaylandi. Buradan koordine olabilirsiniz.';

  @override
  String get chatTitle => 'Koordinasyon sohbeti';

  @override
  String get commonCancel => 'Iptal';

  @override
  String get commonOff => 'Kapali';

  @override
  String get commonOn => 'Acik';

  @override
  String get continueAsGuestPreview => 'Deneyimi incele';

  @override
  String get continueWithPhone => 'Telefon ile devam et';

  @override
  String get createPlanField => 'Alan';

  @override
  String get createPlanFieldCategory => 'Kategori';

  @override
  String get createPlanFieldCity => 'Sehir';

  @override
  String get createPlanFieldDescription => 'Aciklama';

  @override
  String get createPlanFieldDuration => 'Sure';

  @override
  String get createPlanFieldIndoor => 'Kapali mekan tercihi';

  @override
  String get createPlanFieldLocation => 'Yaklasik konum';

  @override
  String get createPlanFieldTime => 'Tarih ve saat';

  @override
  String get createPlanFieldTitle => 'Baslik';

  @override
  String get createPlanPickDateTime => 'Tarih ve saat sec';

  @override
  String get createPlanSubtitle => 'Ilani kisa, net ve katilmasi kolay tut.';

  @override
  String get createPlanTitle => 'Plan detaylari';

  @override
  String get exploreCategoryAll => 'Tumleri';

  @override
  String get exploreCategoryFilters => 'Kategoriler';

  @override
  String get exploreCategoryHint => 'Once gormek istedigin plan turlerini sec.';

  @override
  String get exploreDiscoveryHint =>
      'Deneyimi sonsuz gezinme degil, zaman ve yakinlik yonlendirir.';

  @override
  String get exploreDiscoverySections => 'Kesif yuzeyleri';

  @override
  String get exploreEmptyMessage =>
      'Baska bir yuzey dene ya da insanlarin seni bulmasi icin plan olustur.';

  @override
  String get exploreEmptyTitle => 'Bu gorunume uyan plan yok';

  @override
  String get exploreReasonActivityMatch => 'Sevdigin aktivitelere uyuyor';

  @override
  String get exploreReasonGroupMatch => 'Grup tercihine uyuyor';

  @override
  String get exploreReasonOpenNow => 'Hizli koordinasyona acik';

  @override
  String get exploreReasonTimeMatch => 'Musait zamanina uyuyor';

  @override
  String get exploreSafetyHint =>
      'Insanlar hizli plan yaparken gizlilik ve guven net kalmali.';

  @override
  String get exploreSuggestedPlans => 'Onerilen planlar';

  @override
  String get exploreSuggestedReasonTitle => 'Neden uygun';

  @override
  String get exploreTitle => 'Planlari kesfet';

  @override
  String get finishSetup => 'Kurulumu bitir';

  @override
  String get groupPreferenceFlexible => 'Esnek';

  @override
  String get groupPreferenceOneOnOne => 'Bire bir';

  @override
  String get groupPreferenceSmallGroup => 'Kucuk grup';

  @override
  String get joinOwnPlanNotice => 'Bu plan sana ait.';

  @override
  String get joinPlan => 'Katilim istegi gonder';

  @override
  String get joinPlanFullNotice => 'Bu plan dolu.';

  @override
  String get joinRequestApprovedNotice => 'Bu plan icin onaylandin.';

  @override
  String get joinRequestAwaitingApproval => 'Onay bekleniyor.';

  @override
  String get joinRequestCancel => 'Istegi iptal et';

  @override
  String get joinRequestCancelled => 'Katilim istegi iptal edildi.';

  @override
  String get joinRequestDefaultMessage =>
      'Merhaba, katilabilirim ve kolayca koordine olabilirim.';

  @override
  String get joinRequestDialogHint => 'Mesaji kisa ve pratik tut.';

  @override
  String get joinRequestDialogTitle => 'Katilim istegi gonder';

  @override
  String get joinRequestFieldLabel => 'Mesaj';

  @override
  String get joinRequestPresetFlexible =>
      'Gerekirse saate uyum saglayabilirim.';

  @override
  String get joinRequestPresetNearby => 'Yakinim ve kolayca gelebilirim.';

  @override
  String get joinRequestPresetTimeFit => 'Bu saat benim icin uygun.';

  @override
  String get joinRequestPresetTitle => 'Hazir mesaj fikirleri';

  @override
  String get joinRequestRejectedNotice => 'Bu istek onaylanmadi.';

  @override
  String get joinRequestsEmpty => 'Henuz katilim istegi yok.';

  @override
  String get joinRequestsNoPlanSelected =>
      'Istekleri gormek icin bir plan sec veya olustur.';

  @override
  String joinRequestsPendingCount(int count) {
    return '$count bekleyen istek';
  }

  @override
  String get joinRequestsSubtitle =>
      'Istekleri incele ve onay surecini hafif tut.';

  @override
  String get joinRequestsTitle => 'Katilim istekleri';

  @override
  String get joinRequestSend => 'Istegi gonder';

  @override
  String get joinRequestSent => 'Katilim istegi gonderildi.';

  @override
  String get mapNearbyPlansTitle => 'Yakindaki planlar';

  @override
  String get mapPlaceholder => 'Yaklasik aktivite haritasi onizlemesi';

  @override
  String get mapPrivacyApproximate => 'Yaklasik alan gorunur';

  @override
  String get mapPrivacyHidden => 'Harita gorunurlugu su an gizli.';

  @override
  String get mapPrivacyMessage =>
      'Herkese acik haritalar tam bulusma noktasi degil, bolge duzeyi baglam gostermeli.';

  @override
  String get mapPrivacyTitle => 'Sadece yaklasik harita';

  @override
  String get mapRecommendedEmpty => 'Henuz harita onerisi yok.';

  @override
  String get mapRecommendedTitle => 'Onerilen yakin planlar';

  @override
  String get mapTitle => 'Yakinindaki harita';

  @override
  String get moodCalm => 'Sakin';

  @override
  String get moodCasual => 'Rahat';

  @override
  String get moodEnergetic => 'Enerjik';

  @override
  String get moodFocused => 'Odakli';

  @override
  String get moodGroupFriendly => 'Grup uyumlu';

  @override
  String get navChat => 'Sohbet';

  @override
  String get navExplore => 'Kesfet';

  @override
  String get navMap => 'Harita';

  @override
  String get navPlans => 'Planlar';

  @override
  String get navProfile => 'Profil';

  @override
  String get onboardingActivityPreferencesTitle => 'Sevdigin aktivite turleri';

  @override
  String get onboardingAvailabilityTitle => 'Musaitlik';

  @override
  String onboardingCompletionScore(int score) {
    return '%$score tamamlandi';
  }

  @override
  String get onboardingCompletionTitle => 'Profil tamamlama';

  @override
  String get onboardingFieldBio => 'Kisa biyografi';

  @override
  String get onboardingFieldCity => 'Sehir';

  @override
  String get onboardingFieldGroupPreference => 'Grup tercihi';

  @override
  String get onboardingFieldMood => 'Sosyal ruh hali';

  @override
  String get onboardingFieldName => 'Gorunen ad';

  @override
  String get onboardingItemAvailability => 'Musaitlik ve bildirimler';

  @override
  String get onboardingItemBio => 'Kisa biyografi ve sosyal stil';

  @override
  String get onboardingItemIdentity => 'Gorunen ad ve sehir';

  @override
  String get onboardingItemInterests => 'Ilgi alanlari ve sevdigi aktiviteler';

  @override
  String get onboardingItemPhoto => 'Profil fotografi';

  @override
  String get onboardingProfileHint =>
      'Kurulumu kisa, pratik ve aktivite odakli tut.';

  @override
  String get onboardingProfileSection => 'Profil temelleri';

  @override
  String get onboardingSafetyApproximateLocation =>
      'Yaklasik konum varsayilanlari';

  @override
  String get onboardingSafetyHint =>
      'Ilk bulusmadan once guven araclari gorunur olmali.';

  @override
  String get onboardingSafetyReminder => 'Guvenli bulusma hatirlatmalari';

  @override
  String get onboardingSafetyReportBlock => 'Bildirme ve engelleme araclari';

  @override
  String get onboardingSafetyVerification => 'Dogrulama mimarisi';

  @override
  String get onboardingTitle => 'Guven veren bir profil olustur';

  @override
  String get openExploreAction => 'Kesfi ac';

  @override
  String get openPlansAction => 'Planlari ac';

  @override
  String get openProfileAction => 'Profili ac';

  @override
  String get openSafetyCenterAction => 'Guvenlik merkezini ac';

  @override
  String get openSettingsAction => 'Ayarlari ac';

  @override
  String peopleCount(int current, int max) {
    return '$current/$max kisi';
  }

  @override
  String get planPublishedToast => 'Plan yayinlandi.';

  @override
  String get profileAvailabilityTitle => 'Aktif zamanlar';

  @override
  String profileCompletion(int percent) {
    return '%$percent tamamlandi';
  }

  @override
  String get profileEditSubtitle =>
      'Insanlarin seninle kolay koordine olmasina yardim eden detaylari guncelle.';

  @override
  String get profileEditTitle => 'Profili duzenle';

  @override
  String get profilePhotoAdd => 'Fotograf ekle';

  @override
  String get profilePhotoChange => 'Fotografi degistir';

  @override
  String get profilePhotoEmpty => 'Bos olmayan bir gorsel dosyasi sec.';

  @override
  String get profilePhotoFailed => 'Profil fotografi guncellenemedi.';

  @override
  String get profilePhotoReady => 'Profil fotografi kaydetmeye hazir.';

  @override
  String get profilePhotoRemove => 'Fotografi kaldir';

  @override
  String get profilePhotoSectionSubtitle =>
      'Net ve samimi bir fotograf, bulusma oncesinde insanlarin seni tanimasini kolaylastirir.';

  @override
  String get profilePhotoSectionTitle => 'Profil fotografi';

  @override
  String get profilePhotoTooLarge => '5 MB\'den kucuk bir gorsel sec.';

  @override
  String get profilePhotoUnsupportedType => 'JPG, PNG veya WebP gorsel kullan.';

  @override
  String get profilePhotoUpdated => 'Profil fotografi guncellendi.';

  @override
  String get profilePhotoUploading => 'Fotograf yukleniyor...';

  @override
  String get profileGateAction => 'Profili tamamla';

  @override
  String profileGateMessage(int completion) {
    return 'Plan olusturmak ve katilmak icin profilinin en az %$completion tamamlanmis olmasi gerekiyor.';
  }

  @override
  String get profileGateTitle => 'Once profilini tamamla';

  @override
  String get profileGroupPreferenceTitle => 'Grup tercihi';

  @override
  String profileMoodLabel(String mood) {
    return 'Sosyal ruh hali: $mood';
  }

  @override
  String get profileQuickActionsSubtitle =>
      'Guven ve tercih araclarina hizlica gec.';

  @override
  String get profileQuickActionsTitle => 'Hizli islevler';

  @override
  String get profileSaved => 'Profil kaydedildi.';

  @override
  String get profileTitle => 'Profilin';

  @override
  String get publishPlan => 'Plani yayinla';

  @override
  String get quickReplyConfirmTime => 'Saati netlestirebilir miyiz?';

  @override
  String get quickReplyOnMyWay => 'Yoldayim.';

  @override
  String get quickReplyRunningLate => 'Biraz gecikecegim.';

  @override
  String get quickReplyShareArea => 'Yaklasik bolgeyi paylasacagim.';

  @override
  String get rejectRequest => 'Reddet';

  @override
  String get reportUser => 'Kullaniciyi bildir';

  @override
  String get requestStatusApproved => 'Onaylandi';

  @override
  String get requestStatusCancelled => 'Iptal edildi';

  @override
  String get requestStatusPending => 'Bekliyor';

  @override
  String get requestStatusRejected => 'Reddedildi';

  @override
  String safetyBlockedCount(int count) {
    return '$count engelli';
  }

  @override
  String get safetyBlockedUsersSubtitle =>
      'Engelledigin kullanicilar hafif koordinasyon yuzeylerinden gizli kalir.';

  @override
  String get safetyBlockedUsersTitle => 'Engellenen kullanicilar';

  @override
  String get safetyCenterSubtitle =>
      'Guven araclari basit, dogrudan ve asla gizli olmamali.';

  @override
  String get safetyCenterTitle => 'Guvenlik merkezi';

  @override
  String get safetyEvent => 'Guvenlik olayi';

  @override
  String get safetyEventInternal => 'Dahili guven sinyali';

  @override
  String get safetyEventMeetupReminder => 'Bulusma hatirlatmasi etkin';

  @override
  String get safetyEventPhoneVerified => 'Telefon dogrulandi';

  @override
  String get safetyEventReportSubmitted => 'Bildirim gonderildi';

  @override
  String get safetyEventUserBlocked => 'Kullanici engellendi';

  @override
  String get safetyEventVisible => 'Guvenlik zaman cizelgesinde gorunur';

  @override
  String get safetyReportAlreadySubmitted => 'Bildirim zaten gonderildi';

  @override
  String safetyReportedCount(int count) {
    return '$count bildirim';
  }

  @override
  String get safetyReportSubmittedToast => 'Bildirim gonderildi.';

  @override
  String get safetySummarySubtitle => 'Son guven eylemlerinin hizli ozeti.';

  @override
  String get safetySummaryTitle => 'Guvenlik ozeti';

  @override
  String get safetyTimelineEmpty => 'Henuz guvenlik olayi yok.';

  @override
  String get safetyTimelineSubtitle =>
      'Onemli guven eylemleri burada gorunur kalir.';

  @override
  String get safetyTimelineTitle => 'Guvenlik zaman cizelgesi';

  @override
  String get safetyTitle => 'Guvenlik';

  @override
  String get safetyUserAlreadyBlocked => 'Kullanici zaten engelli';

  @override
  String get safetyUserBlockedToast => 'Kullanici engellendi.';

  @override
  String get saveProfile => 'Profili kaydet';

  @override
  String get settingsApproximateLocation => 'Yaklasik konum kullan';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsPreferences => 'Tercihler';

  @override
  String get settingsPreferencesSubtitle =>
      'Gizlilik, hatirlatma ve koordinasyon varsayilanlarini ayarla.';

  @override
  String get settingsProfileShortcutSubtitle =>
      'Profilini ac ve gorunen detaylari guncelle.';

  @override
  String get settingsSafeMeetupReminders => 'Guvenli bulusma hatirlatmalari';

  @override
  String get settingsSafetyLinkSubtitle =>
      'Bildirme, engelleme ve guven zaman cizelgesi araclarini ac.';

  @override
  String get settingsSafetyLinkTitle => 'Guvenlik araclari';

  @override
  String get settingsSignalsEmpty => 'Henuz sinyal yok.';

  @override
  String get settingsSignalsSubtitle =>
      'Son urun ve guven eylemleri burada gorunur.';

  @override
  String get settingsSignalsSummarySubtitle =>
      'Son kimlik, guvenlik ve koordinasyon eylemlerinin hizli sayimi.';

  @override
  String get settingsSignalsSummaryTitle => 'Sinyal ozeti';

  @override
  String get settingsSignalsTitle => 'Son sinyaller';

  @override
  String get settingsSummarySubtitle =>
      'Mevcut koordinasyon tercihlerini gozden gecir.';

  @override
  String get settingsSummaryTitle => 'Mevcut ayarlar';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get signOut => 'Cikis yap';

  @override
  String get surfaceGroups => 'Gruplar';

  @override
  String get surfaceNearby => 'Yakininda';

  @override
  String get surfaceNow => 'Simdi';

  @override
  String get surfaceTonight => 'Bu aksam';

  @override
  String get surfaceWeekend => 'Hafta sonu';

  @override
  String get trustApprovalDescription =>
      'Sohbet ancak plan sahibi istegi onayladiktan sonra acilir.';

  @override
  String get trustApprovalLabel => 'Sohbetten once onay';

  @override
  String get trustApproximateLocationDescription =>
      'Herkese acik kesif varsayilan olarak bolge duzeyinde kalir.';

  @override
  String get trustApproximateLocationLabel => 'Yaklasik konum';

  @override
  String get trustToolsDescription =>
      'Bildirme ve engelleme araclari kolayca ulasilabilir kalir.';

  @override
  String get trustToolsLabel => 'Guven araclari';

  @override
  String get verificationPhone => 'Telefon dogrulandi';
}
