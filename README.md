
# Tích hợp ZaloPay với Flutter

  
## Nguồn doc chính

- [ZaloPay Document](https://docs.zalopay.vn/v2/docs/apptoapp/guide.html)

## Miêu tả luồng

- **Ứng dụng Flutter** gọi api mua sản phẩm đến **Server**

- **Server** nhận yêu cầu và thực hiện kiểm tra, tính giá tiền, tạo order và lưu order vào database với trạng thái `PENDING`

- **Server** sau khi lưu order thì gọi api gửi yêu cầu tạo order kèm id order (do **Server** tạo) đến **ZaloPay Server**

- **ZaloPay Server** gửi kết quả tạo đơn hàng, quan trọng nhất là `zp_trans_token`đến **Server**. **Server** gửi `zp_trans_token`về cho **Ứng dụng Flutter**

- **Ứng dụng Flutter** sử dụng `zp_trans_token` để thực hiện mở app **ZaloPay**

- Tại app **ZaloPay**, khách hàng tiến hành thực hiện thanh toán

- Sau khi hoàn thành thành, **Ứng dụng Flutter** nhận kết quả từ app **ZaloPay** và show lên màn hình

![zalopay app-app flow](https://docs.zalopay.vn/images/v2/apptoapp-payment-v2.png)

  

## Hướng dẫn chuẩn bị Sandbox

  

- Dùng thiết bị thật (Real device) để cài đặt ứng dụng ZaloPay Sandbox

- Tài khoản đăng nhập để sử dụng ZaloPay Sandbox phải là Tài khoản đã đăng ký sử dụng Zalo

- Người sử dụng sau khi cài đặt ZaloPay Sandbox, cần phải định danh bằng chức năng định danh trên ứng dụng mới sử dụng được cho việc thử nghiệm thanh toán

- Tải app [ZaloPay Sandbox](https://beta-docs.zalopay.vn/docs/developer-tools/test-instructions/test-wallets/)

- Đọc kĩ hướng dẫn bao gồm nhập OTP là `111111`, nạp tiền...

  

## Hướng dẫn tích hợp

### Android

- Tải [SDK của ZaloPay cho Android](https://docs.zalopay.vn/v2/downloads/) (file `zpdk-release-v3.1.aar`)

- Hướng dẫn import file aar :

- Tạo một folder mới tên `zpdk-release-v3.1` để ở `/android`
- Đặt file `zpdk-release-v3.1.aar` vào thư mục đó
- Tạo một file tên là `build.gradle` ở thư mục đó
- Nội dung file `build.gradle` :
```
configurations.maybeCreate("default")
artifacts.add("default", file('zpdk-release-v3.1.aar'))
```
- Truy cập file `/android/settings.gradle` và thêm `include ':zpdk-release-v3.1'` vào dưới `include ':app'`
- Truy cập file `/android/app/build.gradle` thêm vào `implementation project(path: ':zpdk-release-v3.1')` trong dependencies :
```
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation project(path: ':zpdk-release-v3.1')
}
```
- Thực hiện resync, reload project,...
- Tạo một  `MethodChannel` ở màn hình chuẩn bị thanh toán
```
static const MethodChannel platform = MethodChannel('flutter.native/channelPayOrder');
```
- Gọi API mua sản phẩm từ **Server** để nhận `zp_trans_token`
- Sử dụng `zp_trans_token` với `MethodChannel`
```
String response =  "";

try {
    final String result = await platform.invokeMethod('payOrder', {"zptoken": zpToken});
	response = result;
	debugPrint("payOrder Result: '$result'.");
} on PlatformException catch (e) {
	debugPrint("Failed to Invoke: '${e.message}'.");
	response =  "Thanh toán thất bại";
}
debugPrint(response);
```