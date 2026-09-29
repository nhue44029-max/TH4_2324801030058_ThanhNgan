# Sắc Tin – Đọc báo online

Ứng dụng Flutter đọc RSS VnExpress thật, thiết kế cho Android và Windows.

**Lớp: D23KTPM01 · MSSV: 2324801030058 · Họ tên: Thanh Ngân**

Project nằm trực tiếp trong `TH4_2324801030058_ThanhNgan`, package `bao_online`.
Không có thư mục project con `bao_online/`.

## Chạy trên Windows

Mở PowerShell tại thư mục project:

```powershell
cd E:\TH4_2324801030058_ThanhNgan
flutter pub get
flutter analyze
flutter run -d windows
```

Cần Flutter SDK và Visual Studio có workload **Desktop development with C++**.
Đã phát triển và kiểm tra với Flutter 3.47.0 / Dart 3.13.0.
Trong VS Code có thể chọn cấu hình **Sắc Tin · Windows**, rồi nhấn F5.

## Chạy trên Android

Bật USB debugging trên điện thoại, cắm USB và cho phép máy tính kết nối; hoặc mở
Android Emulator trong Android Studio. Nếu SDK yêu cầu giấy phép, xem và chấp nhận
các điều khoản bằng `flutter doctor --android-licenses`.

```powershell
flutter pub get
flutter devices
flutter run -d <ANDROID_DEVICE_ID>
```

Thay `<ANDROID_DEVICE_ID>` bằng ID thực tế từ `flutter devices`.
Tạo APK cài thử:

```powershell
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk` nếu build thành công.
Quyền `android.permission.INTERNET` nằm trong **manifest chính**, nên có hiệu lực
cho cả debug và release. Nguồn tin và ảnh đều dùng HTTPS.

## Đối chiếu đề bài

| Màn hình | Chức năng đã triển khai |
| --- | --- |
| Tin tổng hợp | Tiêu đề ĐỌC BÁO ONLINE, nút tải lại, RSS `tin-noi-bat.rss`, tiêu đề trái/ảnh phải, nguồn và ngày, chạm cả thẻ, kéo làm mới, trạng thái tải/lỗi/rỗng và ảnh thay thế. |
| Chi tiết tin | Đúng bài được chọn: ảnh, tiêu đề, nguồn, ngày giờ và tóm tắt; nút mở đúng URL VnExpress bằng trình duyệt; quay lại giữ danh sách và vị trí cuộn. Không tạo nội dung toàn văn. |
| Chủ đề | 12 ô màu có icon: Thời sự, Thế giới, Kinh doanh, Thể thao, Giải trí, Giáo dục, Sức khỏe, Du lịch, Đời sống, Pháp luật, Xe, Góc nhìn; mỗi chủ đề có RSS riêng. |
| Tin mới nhất | RSS `tin-moi-nhat.rss`, chỉ xét 10 phần tử đầu tiên theo thứ tự RSS; có làm mới và xem chi tiết. Bỏ qua phần tử lỗi/trùng nên có thể ít hơn 10 tin. |
| Cài đặt | Giao diện sáng/tối toàn ứng dụng, lưu bằng shared_preferences, báo lỗi lưu nếu có; đúng thông tin lớp, MSSV, họ tên. |

Thanh điều hướng dưới có đủ 4 mục và luôn hiện, cả khi đọc chi tiết. Giao diện tự
giới hạn chiều rộng khi chạy Windows; trên điện thoại giữ thẻ tin dạng hàng theo PDF mẫu.

## Nguồn RSS

Danh mục chính thức: <https://vnexpress.net/rss>.

| Tên | Đường dẫn tại `https://vnexpress.net/rss/` |
| --- | --- |
| Tin tổng hợp | `tin-noi-bat.rss` |
| Tin mới nhất | `tin-moi-nhat.rss` |
| Thời sự | `thoi-su.rss` |
| Thế giới | `the-gioi.rss` |
| Kinh doanh | `kinh-doanh.rss` |
| Thể thao | `the-thao.rss` |
| Giải trí | `giai-tri.rss` |
| Giáo dục | `giao-duc.rss` |
| Sức khỏe | `suc-khoe.rss` |
| Du lịch | `du-lich.rss` |
| Đời sống | `gia-dinh.rss` |
| Pháp luật | `phap-luat.rss` |
| Xe | `oto-xe-may.rss` |
| Góc nhìn | `goc-nhin.rss` |

HTTP có timeout 20 giây. Parser đọc XML/CDATA, xử lý HTML và entities, lấy ảnh từ
`img`, media hoặc enclosure, xử lý ngày RSS có múi giờ. Bài thiếu tiêu đề/liên kết
hợp lệ bị bỏ qua. RSS sai cấu trúc, rỗng và lỗi mạng có trạng thái riêng. Khi làm
mới lỗi, danh sách đã tải trong phiên được giữ lại kèm thông báo. Ứng dụng không
lưu tin offline và cần Internet để tải tin mới hoặc mở bài gốc.

## Tổ chức file

```text
pubspec.yaml / pubspec.lock         Package và phiên bản phụ thuộc
lib/main.dart                      Khởi động, nạp giao diện đã lưu
lib/app.dart                       App, điều hướng và thanh dưới cố định
lib/models/article.dart            Dữ liệu bài viết, định dạng ngày giờ
lib/models/news_topic.dart         Danh sách chủ đề và URL RSS
lib/services/rss_service.dart      HTTP, XML, HTML, ảnh, ngày và lỗi RSS
lib/services/theme_controller.dart Lưu/khôi phục giao diện
lib/theme/app_theme.dart           Màu sắc, theme sáng và tối
lib/widgets/article_card.dart      Thẻ tin, ảnh/ảnh thay thế, biểu tượng Sắc Tin
lib/screens/feed_page.dart         Danh sách, tải/lỗi/rỗng, làm mới
lib/screens/detail_page.dart       Chi tiết và mở bài gốc
lib/screens/topics_page.dart       Ô chủ đề và danh sách theo chủ đề
lib/screens/settings_page.dart     Cài đặt và thông tin sinh viên
android/app/src/main/AndroidManifest.xml  Internet, tên ứng dụng Android
windows/runner/main.cpp            Tên và kích thước cửa sổ Windows
android/gradle.properties          Cấu hình Kotlin cho project/cache khác ổ đĩa
test/rss_service_test.dart         Kiểm thử parser và lỗi HTTP
test/widget_test.dart              Kiểm thử thao tác, responsive, retry, theme
test/live_rss_test.dart            Kiểm tra 14 endpoint RSS thật
test/fixtures/vnexpress_featured.xml Bản RSS thật dùng riêng cho kiểm thử
integration_test/app_test.dart     Kiểm thử Windows thực tế, ảnh chụp, lưu theme
.vscode/launch.json                Cấu hình F5
```

`flutter create . --project-name bao_online` cũng tạo sẵn các file nền tảng
`android/`, `windows/`, `ios/`, `macos/`, `linux/`, `web/`, cấu hình lint và metadata.
Phạm vi nghiệm thu của bài này là **Android và Windows**.

## Kiểm tra

```powershell
flutter analyze
flutter test
flutter test --dart-define=LIVE_RSS=true
flutter test integration_test/app_test.dart -d windows
```

`flutter test` chạy các ca kiểm tra xác định; bài kiểm tra mạng được bỏ qua trừ khi
có `--dart-define=LIVE_RSS=true`. Các dữ liệu cố ý lỗi trong test chỉ là đầu vào kiểm
tra parser, không được dùng làm tin trong ứng dụng. Bản XML fixture là dữ liệu thật
tải từ VnExpress ngày 29/09/2026 và không khai báo trong assets.

Kiểm thử tích hợp dùng Internet thật, mở một bài gốc trên trình duyệt, kiểm tra
lưu/đọc lại theme trên Windows và xuất ảnh vào `.verification/`. Đóng phiên app đang
chạy trước khi kiểm thử tích hợp để tránh khóa file EXE. Xem `VERIFICATION.md` để biết
kết quả kiểm tra thực tế và các giới hạn của môi trường.
