// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get activePlansEmptyMessage =>
      'Yakınında koordinasyon başlatmak için basit bir plan yayınla.';

  @override
  String get activePlansEmptyTitle => 'Henüz aktif plan yok';

  @override
  String activePlansLimit(int limit) {
    return 'Aynı anda en fazla $limit aktif plan açık tutabilirsin.';
  }

  @override
  String get activePlansTitle => 'Aktif planların';

  @override
  String get activitiesFocusSubtitle =>
      'İstekleri incelerken mevcut planını görünür tut.';

  @override
  String get activitiesFocusTitle => 'Odaktaki plan';

  @override
  String get activitiesTitle => 'Plan oluştur';

  @override
  String get activity => 'Aktivite';

  @override
  String get activityChat => 'Sohbet';

  @override
  String get activityCoffee => 'Kahve';

  @override
  String get activityCowork => 'Birlikte çalışma';

  @override
  String get activityEvent => 'Etkinlik';

  @override
  String get activityGames => 'Oyun';

  @override
  String get activityIndoor => 'Kapalı mekan';

  @override
  String get activityMovie => 'Film';

  @override
  String get activityOutdoor => 'Açık hava';

  @override
  String get activitySports => 'Spor';

  @override
  String get activityStatusCancelled => 'İptal edildi';

  @override
  String get activityStatusCompleted => 'Tamamlandı';

  @override
  String get activityStatusDraft => 'Taslak';

  @override
  String get activityStatusFull => 'Dolu';

  @override
  String get activityStatusOpen => 'Açık';

  @override
  String activityDistanceKm(double distance) {
    final intl.NumberFormat distanceNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String distanceString = distanceNumberFormat.format(distance);

    return '$distanceString km uzakta';
  }

  @override
  String get activityDistanceUnknown => 'Konum izni sonrası mesafe gösterilir';

  @override
  String activityDurationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get activityWalk => 'Yürüyüş';

  @override
  String get analyticsAuthGuestPreviewSelected => 'Misafir önizlemesi seçildi';

  @override
  String get analyticsAuthPhoneSelected => 'Telefonla giriş seçildi';

  @override
  String get analyticsChatMessageSent => 'Sohbet mesajı gönderildi';

  @override
  String get analyticsExploreCategorySelected => 'Keşif kategorisi seçildi';

  @override
  String get analyticsExploreSurfaceSelected => 'Keşif yüzeyi seçildi';

  @override
  String get analyticsJoinRequestApproved => 'Katılım isteği onaylandı';

  @override
  String get analyticsJoinRequestRejected => 'Katılım isteği reddedildi';

  @override
  String get analyticsJoinRequestSubmitted => 'Katılım isteği gönderildi';

  @override
  String get analyticsMapJoinRequestSubmitted =>
      'Haritadan katılım isteği gönderildi';

  @override
  String get analyticsMapNearbyJoinRequestSubmitted =>
      'Yakın haritadan katılım isteği gönderildi';

  @override
  String get analyticsOnboardingCompleted => 'Onboarding tamamlandı';

  @override
  String get analyticsPlanPublished => 'Plan yayınlandı';

  @override
  String get analyticsProfileUpdated => 'Profil güncellendi';

  @override
  String get analyticsSafetyReportSubmitted => 'Güvenlik bildirimi gönderildi';

  @override
  String get analyticsSafetyUserBlocked => 'Kullanıcı engellendi';

  @override
  String get analyticsSessionSignedOut => 'Çıkış yapıldı';

  @override
  String get analyticsSettingsLocationPrivacy =>
      'Yaklaşık konum ayarı güncellendi';

  @override
  String get analyticsSettingsNotifications => 'Bildirim ayarı güncellendi';

  @override
  String get analyticsSettingsSafeMeetup =>
      'Güvenli buluşma hatırlatması güncellendi';

  @override
  String analyticsSummaryAuth(int count) {
    return '$count kimlik işlemi';
  }

  @override
  String analyticsSummaryCoordination(int count) {
    return '$count koordinasyon işlemi';
  }

  @override
  String analyticsSummarySafety(int count) {
    return '$count güvenlik işlemi';
  }

  @override
  String get approveRequest => 'Onayla';

  @override
  String get authSubtitle =>
      'Yakın planlar oluşturmak, başkalarına katılmak ve düşük baskılı şekilde koordine olmak için giriş yap.';

  @override
  String get authTitle => 'Basit bir planla başla';

  @override
  String get authPhoneEmpty => 'Devam etmek için bir telefon numarası gir.';

  @override
  String get authPhoneCodeSentMessage =>
      'Bir doğrulama kodu gönderdik. Telefonla girişi tamamlamak için aşağıya gir.';

  @override
  String get authPhoneCodeSentTitle => 'Doğrulama kodu gönderildi';

  @override
  String get authCodeConfirm => 'Kodu onayla';

  @override
  String get authCodeEmpty => '6 haneli doğrulama kodunu gir.';

  @override
  String get authCodeExpired =>
      'Bu doğrulama kodunun süresi doldu. Telefonla girişi yeniden başlat.';

  @override
  String get authCodeFieldHint => '123456';

  @override
  String get authCodeFieldLabel => 'Doğrulama kodu';

  @override
  String get authCodeInvalid => 'Gönderdiğimiz güncel 6 haneli kodu gir.';

  @override
  String get authCodeResend => 'Kodu tekrar gönder';

  @override
  String get authCodeResent => 'Yeni bir doğrulama kodu gönderdik.';

  @override
  String get authCodeSubmitting => 'Kod doğrulanıyor...';

  @override
  String get authCodeTooManyRequests =>
      'Çok fazla deneme yapıldı. Biraz bekleyip tekrar dene.';

  @override
  String get authPhoneFailed => 'Telefonla giriş şu anda başlatılamadı.';

  @override
  String get authPhoneFieldHelper =>
      'Ulaşılabilir bir numara kullan. +90 gibi ülke kodu eklemek doğrulamayı netleştirir.';

  @override
  String get authPhoneFieldHint => '+90 555 000 00 00';

  @override
  String get authPhoneFieldLabel => 'Telefon numarası';

  @override
  String get authPhoneInvalid => 'Geçerli bir telefon numarası gir.';

  @override
  String get authPhoneSubmitting => 'Telefonla giriş başlatılıyor...';

  @override
  String get authPhoneUnsupported =>
      'Telefon doğrulama arayüzü bu platformda henüz tam bağlanmadı.';

  @override
  String get authPhoneVerificationPending =>
      'Girişi tamamlamak için gönderdiğimiz kodu gir.';

  @override
  String get authOtherMethodsTitle => 'Diğer giriş seçenekleri';

  @override
  String get authOtherMethodsSubtitle =>
      'E-postayı şimdi kullan; Google ve Apple sağlayıcı kurulumu hazır olduğunda bağlanır.';

  @override
  String get authEmailFieldLabel => 'E-posta';

  @override
  String get authEmailFieldHint => 'sen@ornek.com';

  @override
  String get authPasswordFieldLabel => 'Şifre';

  @override
  String get authPasswordFieldHelper => 'En az 6 karakter kullan.';

  @override
  String get authEmailInvalid =>
      'Geçerli bir e-posta ve en az 6 karakterlik şifre gir.';

  @override
  String get authEmailFailed => 'E-posta ile giriş şu anda tamamlanamadı.';

  @override
  String get authProviderFailed =>
      'Bu giriş sağlayıcısı şu anda tamamlanamadı.';

  @override
  String get availabilityAfternoons => 'Öğleden sonraları';

  @override
  String get availabilityEvenings => 'Akşamları';

  @override
  String get availabilityMornings => 'Sabahları';

  @override
  String get availabilityWeekends => 'Hafta sonları';

  @override
  String get blockUser => 'Kullanıcıyı engelle';

  @override
  String get chatSelectedThreadEmpty =>
      'Koordinasyona başlamak için onaylı bir sohbet seç.';

  @override
  String get chatSelectedThreadSubtitle =>
      'Onaylı sohbetler arasında geçiş yap ve tek bir koordinasyon sohbetine odaklan.';

  @override
  String get chatSelectedThreadTitle => 'Seçili sohbet';

  @override
  String chatThreadChipLabel(String activityId, int count) {
    return '$activityId · $count kişi';
  }

  @override
  String chatActivityLabel(String activityId) {
    return 'Aktivite: $activityId';
  }

  @override
  String get chatBlockedThreadsEmptyMessage =>
      'Engellediğin kullanıcılarla bağlantılı sohbetler koordinasyon alanında gizli kalır.';

  @override
  String get chatBlockedThreadsEmptyTitle => 'Engellenen sohbetler gizli kalır';

  @override
  String get chatComposerHint => 'Pratik bir mesaj yaz';

  @override
  String get chatEmptyMessage =>
      'Bir katılım isteği onaylandığında konuşma zamanlama ve buluşma detaylarına odaklanabilir.';

  @override
  String get chatEmptyTitle => 'Henüz onaylı sohbet yok';

  @override
  String get chatHistoryEmpty => 'Henüz mesaj yok.';

  @override
  String get chatHistoryTitle => 'Son mesajlar';

  @override
  String get chatMessageSendFailedToast => 'Mesaj şu anda gönderilemedi.';

  @override
  String chatParticipantsCount(int count) {
    return '$count katılımcı';
  }

  @override
  String get chatPrimaryThreadEmpty =>
      'Koordinasyona başlamak için onaylı bir sohbet seç.';

  @override
  String get chatPrimaryThreadSubtitle =>
      'Ana koordinasyon sohbetin burada sabit kalir.';

  @override
  String get chatPrimaryThreadTitle => 'Ana sohbet';

  @override
  String get chatQuickRepliesHint =>
      'Planı ilerletmek için kısa koordinasyon yanıtları kullan.';

  @override
  String get chatQuickRepliesTitle => 'Hazır yanıtlar';

  @override
  String get chatSafetyBanner =>
      'Herkese açık ve kolay bulunur bir yerde buluş; tam detayları sadece onaylı sohbette paylaş.';

  @override
  String get chatThreadCreatedPreview =>
      'İstek onaylandı. Buradan koordine olabilirsiniz.';

  @override
  String get chatTitle => 'Koordinasyon sohbeti';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonOff => 'Kapalı';

  @override
  String get commonOn => 'Açık';

  @override
  String get continueAsGuestPreview => 'Deneyimi incele';

  @override
  String get continueWithApple => 'Apple ile devam et';

  @override
  String get continueWithEmail => 'E-posta ile devam et';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get continueWithPhone => 'Telefon ile devam et';

  @override
  String get createPlanField => 'Alan';

  @override
  String get createPlanFieldCategory => 'Kategori';

  @override
  String get createPlanFieldCity => 'Şehir';

  @override
  String get createPlanFieldDescription => 'Açıklama';

  @override
  String get createPlanFieldDuration => 'Süre';

  @override
  String get createPlanFieldIndoor => 'Kapalı mekan tercihi';

  @override
  String get createPlanFieldLocation => 'Yaklaşık konum';

  @override
  String get createPlanFieldTime => 'Tarih ve saat';

  @override
  String get createPlanFieldTitle => 'Başlık';

  @override
  String get createPlanPickDateTime => 'Tarih ve saat seç';

  @override
  String get createPlanSubtitle => 'İlanı kısa, net ve katılması kolay tut.';

  @override
  String get createPlanTitle => 'Plan detayları';

  @override
  String get exploreCategoryAll => 'Tümü';

  @override
  String get exploreCategoryFilters => 'Kategoriler';

  @override
  String get exploreCategoryHint => 'Önce görmek istediğin plan türlerini seç.';

  @override
  String get exploreClearFilters => 'Filtreleri sıfırla';

  @override
  String get exploreDiscoveryHint =>
      'Deneyimi sonsuz gezinme değil, zaman ve yakınlık yönlendirir.';

  @override
  String get exploreDiscoverySections => 'Keşif yüzeyleri';

  @override
  String get exploreDistanceFilters => 'Mesafe';

  @override
  String get exploreDistanceHint =>
      'Ne kadar uzağa bakmak istediğini seç. Tam konumlar gizli kalır.';

  @override
  String get exploreEmptyMessage =>
      'Başka bir yüzey dene ya da insanların seni bulması için plan oluştur.';

  @override
  String get exploreEmptyTitle => 'Bu görünüme uyan plan yok';

  @override
  String get exploreFilterTitle => 'Planları filtrele';

  @override
  String get exploreReasonActivityMatch => 'Sevdiğin aktivitelere uyuyor';

  @override
  String get exploreReasonGroupMatch => 'Grup tercihine uyuyor';

  @override
  String get exploreReasonOpenNow => 'Hızlı koordinasyona açık';

  @override
  String get exploreReasonTimeMatch => 'Müsait zamanına uyuyor';

  @override
  String get exploreSafetyHint =>
      'Insanlar hizli plan yaparken gizlilik ve guven net kalmali.';

  @override
  String get exploreSuggestedPlans => 'Önerilen planlar';

  @override
  String get exploreSuggestedReasonTitle => 'Neden uygun';

  @override
  String get exploreTitle => 'Planları keşfet';

  @override
  String get finishSetup => 'Kurulumu bitir';

  @override
  String get groupPreferenceFlexible => 'Esnek';

  @override
  String get groupPreferenceOneOnOne => 'Bire bir';

  @override
  String get groupPreferenceSmallGroup => 'Küçük grup';

  @override
  String get joinOwnPlanNotice => 'Bu plan sana ait.';

  @override
  String get joinPlan => 'Katılım isteği gönder';

  @override
  String get joinPlanFullNotice => 'Bu plan dolu.';

  @override
  String get joinRequestApprovedNotice => 'Bu plan için onaylandın.';

  @override
  String get joinRequestApprovedFirebaseNotice =>
      'İstek onaylandı. Backend kontrolleri bitince sohbet açılacak.';

  @override
  String get joinRequestApprovedLocalNotice =>
      'İstek onaylandı. Koordinasyon sohbeti hazır.';

  @override
  String get joinRequestAwaitingApproval => 'Onay bekleniyor.';

  @override
  String get joinRequestCancel => 'İsteği iptal et';

  @override
  String get joinRequestCancelled => 'Katılım isteği iptal edildi.';

  @override
  String get joinRequestDefaultMessage =>
      'Merhaba, katılabilirim ve kolayca koordine olabilirim.';

  @override
  String get joinRequestDialogHint => 'Mesajı kısa ve pratik tut.';

  @override
  String get joinRequestDialogTitle => 'Katılım isteği gönder';

  @override
  String get joinRequestFieldLabel => 'Mesaj';

  @override
  String get joinRequestPresetFlexible =>
      'Gerekirse saate uyum sağlayabilirim.';

  @override
  String get joinRequestPresetNearby => 'Yakınım ve kolayca gelebilirim.';

  @override
  String get joinRequestPresetTimeFit => 'Bu saat benim için uygun.';

  @override
  String get joinRequestPresetTitle => 'Hazır mesaj fikirleri';

  @override
  String get joinRequestRejectedNotice => 'Bu istek onaylanmadı.';

  @override
  String get joinRequestRejectedLocalNotice => 'İstek reddedildi.';

  @override
  String get joinRequestsEmpty => 'Henüz katılım isteği yok.';

  @override
  String joinRequestsPlanContext(String title, String schedule) {
    return '$title · $schedule için istekler inceleniyor';
  }

  @override
  String get joinRequestsNoPlanSelected =>
      'İstekleri görmek için bir plan seç veya oluştur.';

  @override
  String joinRequestsPendingCount(int count) {
    return '$count bekleyen istek';
  }

  @override
  String get joinRequestsSubtitle =>
      'İstekleri incele ve onay sürecini hafif tut.';

  @override
  String get joinRequestsTitle => 'Katılım istekleri';

  @override
  String get joinRequestSend => 'İsteği gönder';

  @override
  String get joinRequestSent => 'Katılım isteği gönderildi.';

  @override
  String get mapNearbyPlansTitle => 'Yakındaki planlar';

  @override
  String get mapLocationUnavailableMessage =>
      'Haritayı bulunduğun bölgeye göre ortalamak ve plan işaretlerini yaklaşık tutmak için konum izni ver.';

  @override
  String get mapLocationUnavailableTitle =>
      'Yakındaki harita için konum gerekli';

  @override
  String get mapOpenLocationSettingsAction => 'Konum ayarlarını aç';

  @override
  String get mapCurrentAreaLabel => 'Bulunduğun bölge';

  @override
  String get mapApproximateMarkerHint =>
      'Plan işaretleri tam buluşma noktası yerine yakın yaklaşık alanlara bilinçli olarak kaydırılır.';

  @override
  String get mapPlaceholder => 'Yaklaşık aktivite haritası önizlemesi';

  @override
  String get mapPrivacyApproximate => 'Yaklaşık alan görünür';

  @override
  String get mapPrivacyHidden => 'Harita görünürlüğü şu an gizli.';

  @override
  String get mapPrivacyMessage =>
      'Herkese açık haritalar tam buluşma noktası değil, bölge düzeyi bağlam göstermeli.';

  @override
  String get mapPrivacyTitle => 'Sadece yaklaşık harita';

  @override
  String get mapRecommendedEmpty => 'Henüz harita önerisi yok.';

  @override
  String get mapRecommendedTitle => 'Önerilen yakın planlar';

  @override
  String get mapTitle => 'Yakınındaki harita';

  @override
  String get mapUnsupportedPlatform =>
      'Etkileşimli harita şu anda Android, iOS ve Web üzerinde kullanılabiliyor.';

  @override
  String get moodCalm => 'Sakin';

  @override
  String get moodCasual => 'Rahat';

  @override
  String get moodEnergetic => 'Enerjik';

  @override
  String get moodFocused => 'Odaklı';

  @override
  String get moodGroupFriendly => 'Grup uyumlu';

  @override
  String get navChat => 'Sohbet';

  @override
  String get navExplore => 'Keşfet';

  @override
  String get navMap => 'Harita';

  @override
  String get navPlans => 'Planlar';

  @override
  String get navProfile => 'Profil';

  @override
  String get onboardingActivityPreferencesTitle => 'Sevdiğin aktivite türleri';

  @override
  String get onboardingAvailabilityTitle => 'Müsaitlik';

  @override
  String onboardingCompletionScore(int score) {
    return '%$score tamamlandı';
  }

  @override
  String get onboardingCompletionTitle => 'Profil tamamlama';

  @override
  String get onboardingFieldBio => 'Kisa biyografi';

  @override
  String get onboardingFieldCity => 'Şehir';

  @override
  String get onboardingFieldGroupPreference => 'Grup tercihi';

  @override
  String get onboardingFieldMood => 'Sosyal ruh hali';

  @override
  String get onboardingFieldName => 'Görünen ad';

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
  String get openExploreAction => 'Keşfi aç';

  @override
  String get openPlansAction => 'Planları aç';

  @override
  String get openProfileAction => 'Profili ac';

  @override
  String get openSafetyCenterAction => 'Güvenlik merkezini aç';

  @override
  String get guestPreviewLabel => 'Misafir önizlemesi';

  @override
  String get openSettingsAction => 'Ayarları aç';

  @override
  String get exploreOpenSpotsOnly => 'Sadece boş yeri olanlar';

  @override
  String get exploreAdvancedFiltersUpsell =>
      'İç mekân ve uygunluk filtrelerinin gelişmiş sürümü Plus veya Pro ile açılır.';

  @override
  String peopleCount(int current, int max) {
    return '$current/$max kişi';
  }

  @override
  String get planPublishedToast => 'Plan yayınlandı.';

  @override
  String get profileAvailabilityTitle => 'Aktif zamanlar';

  @override
  String profileCompletion(int percent) {
    return '%$percent tamamlandı';
  }

  @override
  String get profileEditSubtitle =>
      'Insanlarin seninle kolay koordine olmasina yardim eden detaylari guncelle.';

  @override
  String get profileEditTitle => 'Profili düzenle';

  @override
  String get profilePhotoAdd => 'Fotoğraf ekle';

  @override
  String get profilePhotoChange => 'Fotoğrafı değiştir';

  @override
  String get profilePhotoEmpty => 'Bos olmayan bir gorsel dosyasi sec.';

  @override
  String get profilePhotoFailed => 'Profil fotografi guncellenemedi.';

  @override
  String get profilePhotoReady => 'Profil fotografi kaydetmeye hazir.';

  @override
  String get profilePhotoRemove => 'Fotoğrafı kaldır';

  @override
  String get profilePhotoSectionSubtitle =>
      'Net ve samimi bir fotograf, bulusma oncesinde insanlarin seni tanimasini kolaylastirir.';

  @override
  String get profilePhotoSectionTitle => 'Profil fotoğrafı';

  @override
  String get profilePhotoTooLarge => '5 MB\'den kucuk bir gorsel sec.';

  @override
  String get profilePhotoUnsupportedType => 'JPG, PNG veya WebP gorsel kullan.';

  @override
  String get profilePhotoUpdated => 'Profil fotografi guncellendi.';

  @override
  String get profilePhotoUploading => 'Fotograf yukleniyor...';

  @override
  String get profileGateAction => 'Birkaç detay ekle';

  @override
  String profileGateMessage(int completion) {
    return 'Profiline birkaç detay daha ekleyip %$completion tamamlanma seviyesine ulaş; planlara daha rahat katılabilir veya plan oluşturabilirsin.';
  }

  @override
  String get profileGateTitle => 'Profiline biraz daha detay ekle';

  @override
  String get profileGroupPreferenceTitle => 'Grup tercihi';

  @override
  String memberLabel(String memberId) {
    return 'Üye $memberId';
  }

  @override
  String profileMoodLabel(String mood) {
    return 'Sosyal ruh hali: $mood';
  }

  @override
  String get profileQuickActionsSubtitle =>
      'Guven ve tercih araclarina hizlica gec.';

  @override
  String get profileQuickActionsTitle => 'Hızlı işlemler';

  @override
  String get profileSaved => 'Profil kaydedildi.';

  @override
  String get profileTitle => 'Profilin';

  @override
  String get publishPlan => 'Planı yayınla';

  @override
  String get premiumBoosts => 'Öne çıkarılan planlar';

  @override
  String get premiumFilters => 'Premium filtreler';

  @override
  String get premiumRecurringPlans => 'Tekrarlayan planlar';

  @override
  String get premiumSlots => 'Daha fazla aktif plan hakkı';

  @override
  String get premiumTierPlus => 'Plus';

  @override
  String get premiumTierPro => 'Pro / Host';

  @override
  String get premiumPlusSummary =>
      'Daha fazla aktif plan, gelişmiş filtreler, geniş keşif alanı ve dahil boost hakları.';

  @override
  String get premiumProSummary =>
      'Tekrarlayan planlar, host kontrolleri, daha güçlü görünürlük araçları ve gelişmiş katılım yönetimi.';

  @override
  String get boostedBadge => 'Öne çıktı';

  @override
  String get boostPlanAction => 'Planı öne çıkar';

  @override
  String get boostPlanWithAdAction => 'Reklam izle, öne çıkar';

  @override
  String get unlockBoostAction => 'Boost kilidini aç';

  @override
  String get activityBoostHint =>
      'Boost verilen planlar normal içerikleri gizlemeden keşifte biraz daha yukarı çıkar.';

  @override
  String activityBoostedToast(String title) {
    return '$title planı sınırlı süre için öne çıkarıldı.';
  }

  @override
  String activityBoostedUntil(String time) {
    return 'Boost şu zamana kadar aktif: $time.';
  }

  @override
  String get monetizationVisibilityToolsTitle => 'Görünürlük araçları';

  @override
  String get monetizationVisibilityToolsFreeSubtitle =>
      'Boost tamamen isteğe bağlıdır. Ücretsiz kullanıcılar isterse ödüllü reklam ile ek görünürlük alabilir.';

  @override
  String monetizationVisibilityToolsPremiumSubtitle(String tier) {
    return '$tier, keşifte adil ek görünürlük ve ek araçlar sunar.';
  }

  @override
  String monetizationBoostCredits(int count) {
    return '$count dahil boost hakkı';
  }

  @override
  String get monetizationRewardedBoost => 'Ödüllü boost hazır';

  @override
  String get monetizationRewardedAdUnavailable =>
      'Ödüllü reklam şu anda kullanılamıyor.';

  @override
  String get monetizationPremiumComingSoon =>
      'Premium ödeme akışı hazırlandı ama satış henüz açılmadı.';

  @override
  String get monetizationRewardedAdsHint =>
      'Ödüllü reklamlar isteğe bağlıdır; sohbeti, katılımı veya plan oluşturmayı bölmez.';

  @override
  String get quickReplyConfirmTime => 'Saati netleştirebilir miyiz?';

  @override
  String get quickReplyOnMyWay => 'Yoldayım.';

  @override
  String get quickReplyRunningLate => 'Biraz gecikeceğim.';

  @override
  String get quickReplyShareArea => 'Yaklaşık bölgeyi paylaşacağım.';

  @override
  String get rejectRequest => 'Reddet';

  @override
  String get reportUser => 'Kullanıcıyı bildir';

  @override
  String get requestStatusApproved => 'Onaylandı';

  @override
  String get requestStatusCancelled => 'İptal edildi';

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
  String get safetyReportReasonDialogHint =>
      'Moderasyon ve guvenlik incelemesi tutarli kalsin diye en yakin nedeni sec.';

  @override
  String get safetyReportReasonDialogTitle =>
      'Bu kullaniciyi neden bildiriyorsun?';

  @override
  String get safetyReportReasonFakeProfile => 'Sahte profil';

  @override
  String get safetyReportReasonHarassment => 'Taciz';

  @override
  String get safetyReportReasonInappropriateContent => 'Uygunsuz icerik';

  @override
  String get safetyReportReasonSpam => 'Spam';

  @override
  String get safetyReportReasonUnsafeMeetup => 'Guvensiz bulusma davranisi';

  @override
  String safetyReportedCount(int count) {
    return '$count bildirim';
  }

  @override
  String get safetyReportSubmittedToast => 'Bildirim gonderildi.';

  @override
  String safetyReportsPrivateHint(int count) {
    return '$count bildirim kaydi gizli kalir ve burada sadece ozet olarak gorunur.';
  }

  @override
  String get safetyReportsPrivateLabel => 'Gizli bildirimler';

  @override
  String get safetyReportsPrivateSummary =>
      'Bildirimler gizli kalir ve yalnizca hafif bir ozet olarak gorunur.';

  @override
  String get safetyReportsTitle => 'Bildirim gorunurlugu';

  @override
  String get safetyActionUnavailableToast =>
      'Guvenlik araclari su anda aktif bir oturum gerektiriyor.';

  @override
  String get safetyActionFailedToast =>
      'Guvenlik eylemi su anda tamamlanamadi.';

  @override
  String get safetySummarySubtitle => 'Son guven eylemlerinin hizli ozeti.';

  @override
  String get safetySummaryTitle => 'Guvenlik ozeti';

  @override
  String get safetyTargetEmpty =>
      'Incelenecek biri oldugunda son sohbetler ve katilim istekleri burada gorunur.';

  @override
  String get safetyTargetFieldLabel => 'Bir uye sec';

  @override
  String get safetyTargetSubtitle =>
      'Bildirmeden veya engellemeden once koordinasyon etkinliginden bir uye sec.';

  @override
  String get safetyTargetTitle => 'Incelenecek kisiyi sec';

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
  String get settingsApproximateLocation => 'Yaklaşık konum kullan';

  @override
  String get settingsLanguageSubtitle =>
      'Tüm ekranlarda kullanılacak uygulama dilini seç.';

  @override
  String get settingsLanguageTitle => 'Dil';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsPremiumSubtitle =>
      'Henüz satışta değil; uygulama, flört mekaniğine dönüşmeden ilerideki ücretli seçeneklere hazır.';

  @override
  String get settingsPremiumTitle => 'Premium hazırlığı';

  @override
  String settingsPremiumCurrentTier(String tier) {
    return 'Mevcut paket: $tier';
  }

  @override
  String get settingsPreferences => 'Tercihler';

  @override
  String get settingsPreferencesSubtitle =>
      'Gizlilik, hatırlatma ve koordinasyon varsayılanlarını ayarla.';

  @override
  String get settingsProfileShortcutSubtitle =>
      'Profilini ac ve gorunen detaylari guncelle.';

  @override
  String get settingsSafeMeetupReminders => 'Güvenli buluşma hatırlatmaları';

  @override
  String get settingsSafetyLinkSubtitle =>
      'Bildirme, engelleme ve güven zaman çizelgesi araçlarını aç.';

  @override
  String get settingsSafetyLinkTitle => 'Güvenlik araçları';

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
      'Mevcut koordinasyon tercihlerini gözden geçir.';

  @override
  String get settingsSummaryTitle => 'Mevcut ayarlar';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get distanceFilterAny => 'Tüm mesafeler';

  @override
  String distanceFilterKm(int km) {
    return '$km km içinde';
  }

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get surfaceGroups => 'Gruplar';

  @override
  String get surfaceNearby => 'Yakınında';

  @override
  String get surfaceNow => 'Şimdi';

  @override
  String get surfaceTonight => 'Bu akşam';

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
  String get trustApproximateLocationLabel => 'Yaklaşık konum';

  @override
  String get trustToolsDescription =>
      'Bildirme ve engelleme araclari kolayca ulasilabilir kalir.';

  @override
  String get trustToolsLabel => 'Guven araclari';

  @override
  String get verificationPhone => 'Telefon doğrulandı';

  @override
  String planOwnerLabel(String memberId) {
    return 'Plan sahibi: $memberId';
  }
}
