# Velvet kurulum rehberi

Bu sürümde demo giriş kaldırıldı; Google OAuth, video giriş ekranı, LiveKit çift yönlü ses, gerçek mikrofon/hoparlör kontrolleri, gerçek zamanlı oda mesajları ve kalıcı profil altyapısı eklendi.

**Önemli:** Google ve LiveKit dış servislerdir. Kod hazırdır; aşağıdaki panel ayarları yapılmadan giriş ve ses açılamaz.

## 1. Flutter projesini oluşturun

Flutter 3.24 veya yenisini kurun. ZIP’i açıp klasörde çalıştırın:

```bash
flutter create --platforms=android,ios --project-name velvet_app --org com.velvet .
flutter pub get
```

## 2. Profilleri ve mesajları kurun

Mevcut Supabase projenizin SQL Editor bölümünde `database/velvet_realtime.sql` dosyasını çalıştırın. Dosya kalıcı profilleri, oda mesajlarını, güvenlik kurallarını, yeni üyeye otomatik profil oluşturmayı ve canlı mesaj akışını kurar.

Eski üyeler için bir kez çalıştırın:

```sql
insert into public.profiles (id, display_name, avatar_url)
select id, left(coalesce(raw_user_meta_data->>'full_name', split_part(email, '@', 1)), 40), raw_user_meta_data->>'avatar_url'
from auth.users on conflict (id) do nothing;
```

## 3. Google ile girişi açın

1. Google Cloud Console → OAuth consent screen bölümünü tamamlayın.
2. Android OAuth istemcisi oluşturun. Paket adı: `com.velvet.velvet_app`.
3. Debug ve Codemagic release SHA-1/SHA-256 değerlerini Google Console’a ekleyin.
4. iOS OAuth istemcisini oluşturup Flutter’ın ürettiği bundle kimliğini kaydedin.
5. Supabase → Authentication → Providers → Google’da Client ID ve Client Secret girin.
6. Supabase → Authentication → URL Configuration → Redirect URLs listesine `com.velvet.app://login-callback` ekleyin.
7. Android `AndroidManifest.xml` içindeki ana activity’ye şu dönüş bağlantısını ekleyin:

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="com.velvet.app" android:host="login-callback" />
</intent-filter>
```

8. iOS için Xcode → Runner → Info → URL Types içine `com.velvet.app` scheme’ini ekleyin.

## 4. Gerçek sesli odayı açın

1. `https://cloud.livekit.io` üzerinde test projesi açın.
2. Project Settings’den `LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET` alın.
3. Supabase Edge Functions içinde `livekit-token` fonksiyonu açıp `token-server/index.ts` içeriğini kullanın.
4. Üç LiveKit değerini Edge Function Secrets bölümüne ekleyin. API secret Flutter koduna yazılmamalıdır.
5. Fonksiyonu yayınlayın. Adres şu biçimde olur: `https://PROJE.supabase.co/functions/v1/livekit-token`.

CLI kullanıyorsanız:

```bash
supabase functions new livekit-token
# token-server/index.ts içeriğini oluşan index.ts dosyasına koyun
supabase secrets set LIVEKIT_URL=wss://PROJE.livekit.cloud
supabase secrets set LIVEKIT_API_KEY=DEGER
supabase secrets set LIVEKIT_API_SECRET=DEGER
supabase functions deploy livekit-token
```

Token sunucusu gerçek oturumu doğrular ve yalnızca iki saatlik oda erişimi verir. Gizli LiveKit anahtarı APK’ya girmez.

## 5. Mikrofon ve hoparlör izinleri

Android `android/app/src/main/AndroidManifest.xml` içine `<application>` öncesinde ekleyin:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

iOS `ios/Runner/Info.plist` içine ekleyin:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Velvet sesli odalarda konuşabilmeniz için mikrofon erişimi ister.</string>
```

Mikrofon düğmesi gerçek yayını açar/kapatır. Ses düğmesi hoparlör çıkışını değiştirir. Konuşan kişi göstergesi gerçek ses algılamasından gelir.

## 6. Giriş videosu

`lib/giris.mp4` sessiz ve döngülü oynar. Video açılamazsa koyu yedek arka plan görünür. Kaynak video üçüncü taraf indirici adıyla geldiği için kullanım hakkını doğrulayın; mağaza yayını öncesi kendi lisanslı videonuzla değiştirin.

## 7. Codemagic ile APK

1. Klasörü GitHub/GitLab/Bitbucket’a yükleyip Codemagic’e bağlayın.
2. Team settings → Environment variable groups altında `velvet_config` grubu açın.
3. `LIVEKIT_TOKEN_ENDPOINT` ekleyin: `https://PROJE.supabase.co/functions/v1/livekit-token`.
4. `Velvet Android APK` akışını başlatın.
5. Bittiğinde Artifacts içinden `app-release.apk` indirin.

Google girişinin release sürümünde çalışması için gerçek keystore SHA-1/SHA-256 değerlerini Google Cloud’a ekleyin. Play Store için Codemagic’e kendi keystore’unuzu bağlayın.

## 8. İki gerçek telefonla test

1. APK’yı iki telefona kurun, iki farklı hesapla giriş yapın.
2. İki telefonda aynı canlı odayı açın.
3. Mikrofon iznini verip mikrofonu açın.
4. Bir telefonda konuşunca diğerinde ses duyulmalı ve konuşan göstergesi hareket etmelidir.
5. Hoparlör düğmesiyle ses çıkışını kontrol edin.
6. Bir telefondan mesaj gönderin; diğerinde anında görünmelidir.

## 9. Üretim öncesi

Oda yöneticisi, susturma, engelleme ve raporlama ekleyin; gerçek yaş doğrulaması uygulayın; mesaj saklama politikasını açıklayın; veritabanı güvenlik denetimini çalıştırın; LiveKit kota alarmı kurun; lisansı belirsiz videoyu değiştirin.
