# Kết quả kiểm tra Sắc Tin

Ngày kiểm tra: **29/09/2026**, trên Windows 11, Flutter 3.47.0 / Dart 3.13.0.

## Kết quả cuối cùng

| Lệnh / hạng mục | Kết quả thực tế |
| --- | --- |
| `flutter create . --project-name bao_online` | Thành công. Project nằm tại thư mục gốc; không có thư mục con `bao_online/`. |
| `flutter pub get` | Thành công; đã tạo `pubspec.lock`. |
| `flutter analyze` | **No issues found!** |
| `flutter test --dart-define=LIVE_RSS=true` | **12 tests passed**: 9 parser/HTTP, 2 widget, 1 kiểm tra trực tiếp 14 RSS. |
| `flutter run -d windows` | **Đã build và mở được ứng dụng Windows**, Flutter kết nối Dart VM Service thành công. |
| `flutter test integration_test/app_test.dart -d windows` | **1 test passed** với dữ liệu RSS thật và plugin Windows thật. |
| `flutter build apk --debug` | **Thành công**. APK ở `build/app/outputs/flutter-apk/app-debug.apk`. |
| Chạy trên Android thật / emulator | **Chưa kiểm tra** vì không có thiết bị Android đang kết nối. Build APK không thay thế kiểm thử trên thiết bị. |

## Những hành vi đã kiểm tra

- XML RSS tải thực tế: tiêu đề, liên kết, ảnh CDN, tóm tắt và ngày đăng có múi giờ.
- Cả 14 endpoint trả dữ liệu hợp lệ: tin nổi bật, tin mới nhất và 12 chủ đề.
  Tại lần kiểm tra cuối: tin nổi bật có 25 bài, tin mới nhất lấy 10 bài, mỗi chủ đề
  có 60 bài. Các con số có thể thay đổi theo dữ liệu VnExpress.
- Mục Tin mới nhất chỉ xét 10 phần tử đầu tiên, không sắp xếp lại nguồn.
- HTML entity, xuống dòng/đoạn, bỏ script, thiếu ảnh/ngày, ảnh enclosure, URL ảnh tương đối,
  loại bài thiếu link/tiêu đề, loại link không thuộc VnExpress và bài trùng.
- XML lỗi, RSS rỗng, phản hồi HTTP lỗi, mất mạng và byte UTF-8 lỗi có xử lý.
- Retry tải lại được; làm mới thất bại giữ tin của lần tải trước và hiện thông báo.
- Chạm phía ảnh trong thẻ cũng mở đúng bài; quay lại danh sách; thanh dưới vẫn hiện.
- Chọn Thể thao gọi đúng `the-thao.rss`; chuyển 4 tab và tải lại danh sách hoạt động.
- Layout widget không phát sinh overflow ở 320×740, 390×844 và 1120×820.
- Windows tích hợp: mở bài đầu tiên với đúng đối tượng tin đã chọn, thao tác nút đọc
  bài gốc qua plugin `url_launcher` thành công, không có lỗi mở trình duyệt.
- Công tắc tối cập nhật theme toàn ứng dụng. Một `ThemeController` mới đọc lại được
  giá trị đã lưu trên Windows, không có lỗi bộ nhớ. Kiểm thử khôi phục tùy chọn ban đầu.
- Đúng chuỗi thông tin sinh viên: **Lớp: D23KTPM01 · MSSV: 2324801030058 · Họ tên: Thanh Ngân**.

## Đối chiếu với PDF

Đã mở và xem trang duy nhất của `F:\TH4_UngDungDocBaoOnline.pdf` bằng trình render
PDF có sẵn của Windows. Giữ các đặc điểm mẫu: tiêu đề ĐỌC BÁO ONLINE, tải lại ở
góc phải, danh sách dọc với chữ bên trái và ảnh bên phải, nguồn/ngày dưới tiêu đề,
thanh dưới 4 mục. Bổ sung thẻ bo góc, màu san hô/tím/xanh ngọc/vàng và theme tối.

## Ảnh kiểm tra

Ảnh do ứng dụng Windows thực tế render trong kiểm thử tích hợp; ảnh điện thoại là
viewport mô phỏng trong cùng runtime, **không phải ảnh chụp thiết bị Android**.

- `.verification/windows-light.png`
- `.verification/windows-dark.png`
- `.verification/windows-detail.png`
- `.verification/windows-topics.png`
- `.verification/windows-latest.png`
- `.verification/windows-settings-dark.png`
- `.verification/phone-light.png`
- `.verification/phone-dark.png`
- `.verification/phone-topics.png`

Đã xem ảnh để xác nhận chữ rõ ràng, ảnh thật hiển thị và bố cục không tràn.
Các file `.verification/` là bằng chứng kiểm tra tại máy hiện tại, không được đóng
gói vào ứng dụng và được loại khỏi Git.

## Điều chỉnh môi trường Android

Build ban đầu lỗi Kotlin incremental cache ở hai plugin Android vì project trên
ổ E: còn Pub cache trên C:. Đã thêm `kotlin.incremental=false` trong
`android/gradle.properties` và build lại thành công. Đây là tùy chọn của Kotlin được
mô tả trong [tài liệu chính thức](https://kotlinlang.org/docs/gradle-compilation-and-caches.html).
Chỉ thay đổi cấu hình của project; không đổi Flutter SDK, JDK hay cache chung.

`flutter doctor -v` báo trạng thái Android licenses chưa xác định, dù build APK
đã thành công với SDK đang cài. Nếu chạy trên máy khác yêu cầu giấy phép, thực hiện
`flutter doctor --android-licenses` rồi kiểm tra lại `flutter doctor`.

## Giới hạn đã ghi nhận

- Chưa chạy Android trên thiết bị/emulator; chưa kiểm tra iOS, macOS, Linux hoặc web.
- Không lưu tin offline; lần mở mới cần mạng. Trong phiên, tin tải thành công được
  giữ khi làm mới lỗi. Không có dữ liệu tin viết sẵn dùng thay RSS.
- RSS chỉ cung cấp tóm tắt; toàn văn được đọc trên VnExpress bằng trình duyệt.
- Bộ test parser có dữ liệu lỗi chủ động để kiểm thử, và một bản RSS thật đã chụp.
  Những file này không nằm trong assets và không được ứng dụng sử dụng.

Danh sách file nguồn/cấu hình tạo trong project: `FILES_CREATED.txt`.
Hướng dẫn Windows, Android và bảng 5 màn hình: `README.md`.
