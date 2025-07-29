# دليل زيت السيارات - Car Oil Guide Flutter App

## 📱 وصف التطبيق / App Description

تطبيق شامل لدليل زيت السيارات يوفر معلومات دقيقة عن مواصفات الزيت لجميع أنواع السيارات في الأسواق العربية والعالمية. يدعم التطبيق عدة طرق لإدخال بيانات السيارة ويقدم توصيات مفصلة لنوع الزيت المناسب.

A comprehensive car oil guide app that provides accurate oil specifications for all car types in Arabic and international markets. The app supports multiple methods for entering car data and provides detailed recommendations for the appropriate oil type.

## ✨ الميزات الرئيسية / Key Features

### 🔍 طرق إدخال البيانات / Data Input Methods
- **مسح رقم VIN**: قراءة رقم VIN عبر الكاميرا باستخدام تقنية OCR
- **تحميل صورة**: اختيار صورة VIN من معرض الصور
- **إدخال يدوي لـ VIN**: إدخال رقم VIN مباشرة
- **إدخال تفاصيل السيارة**: إدخال العلامة التجارية والموديل والسنة

### 🛢️ معلومات شاملة عن الزيت / Comprehensive Oil Information
- نوع الزيت الموصى به (5W-30, 0W-20, إلخ)
- السعة مع الفلتر وبدونه
- العلامات التجارية المُوصى بها
- فترات تغيير الزيت
- نوع الفلتر المناسب
- عزم براغي التصريف
- شهادات API والمواصفات الفنية

### 🌍 دعم الأسواق المختلفة / Multi-Market Support
- **السيارات الأمريكية والعالمية**: استخدام NHTSA Vehicle API
- **السيارات الخليجية والصينية**: قاعدة بيانات محلية شاملة
- دعم كامل للغة العربية مع اتجاه RTL

### 💾 إدارة البيانات / Data Management
- تخزين محلي للبيانات المُستخدمة بكثرة
- تاريخ البحث والمراجعة
- مشاركة النتائج وتصدير تقارير PDF
- مزامنة مع قاعدة بيانات Supabase

## 🏗️ البنية التقنية / Technical Architecture

### Clean Architecture
```
lib/
├── core/                   # الوظائف الأساسية
│   ├── constants/          # الثوابت والإعدادات
│   ├── errors/            # معالجة الأخطاء
│   ├── network/           # طبقة الشبكة
│   └── utils/             # أدوات مساعدة
├── domain/                # طبقة المنطق
│   ├── entities/          # الكائنات الأساسية
│   ├── repositories/      # واجهات المستودعات
│   └── usecases/          # حالات الاستخدام
├── data/                  # طبقة البيانات
│   ├── datasources/       # مصادر البيانات
│   ├── models/           # نماذج البيانات
│   └── repositories/      # تنفيذ المستودعات
└── presentation/          # طبقة العرض
    ├── pages/            # الصفحات
    ├── widgets/          # المكونات
    └── controllers/      # متحكمات الحالة
```

### 🛠️ التقنيات المستخدمة / Technologies Used

#### Frontend
- **Flutter 3.x**: إطار العمل الأساسي
- **GetX**: إدارة الحالة والتوجيه
- **Material Design 3**: نظام التصميم

#### Backend & Database
- **Supabase**: قاعدة البيانات والمصادقة
- **NHTSA Vehicle API**: فك تشفير VIN للسيارات الأمريكية
- **Hive**: التخزين المحلي والذاكرة التخزينية

#### Image Processing & Recognition
- **Google ML Kit**: تقنية التعرف على النص (OCR)
- **Camera Plugin**: التحكم في الكاميرا
- **Image Picker**: اختيار الصور

#### Networking & APIs
- **Dio**: مكتبة HTTP لاستدعاء APIs
- **HTTP**: دعم إضافي للشبكة

#### UI/UX
- **Google Fonts**: خطوط مخصصة
- **Flutter SVG**: دعم ملفات SVG
- **Cupertino Icons**: أيقونات iOS

#### Utilities
- **Intl**: التدويل والتوطين
- **Path Provider**: إدارة مسارات الملفات
- **Permission Handler**: إدارة أذونات التطبيق
- **Share Plus**: مشاركة المحتوى
- **PDF**: تصدير تقارير PDF

## 📊 قاعدة البيانات / Database Schema

### جدول مواصفات الزيت / Oil Specifications Table
```sql
car_oil_specs (
  id, brand, model, year_from, year_to,
  engine_type, oil_type, oil_capacity_with_filter,
  oil_capacity_without_filter, filter_type,
  oil_change_interval_km, api_certification, etc.
)
```

### جدول تعديلات السيارات / Car Modifications Table
```sql
car_modifications (
  id, car_oil_spec_id, modification_type,
  modified_oil_type, modification_notes, etc.
)
```

### جدول تاريخ البحث / Search History Table
```sql
search_history (
  id, user_device_id, vin_number, brand,
  model, year, search_method, result_found, etc.
)
```

## 🚀 طريقة التشغيل / How to Run

### المتطلبات / Prerequisites
```bash
# تثبيت Flutter SDK
flutter --version  # يجب أن يكون 3.16.0 أو أحدث

# تثبيت Dart SDK (يأتي مع Flutter)
dart --version
```

### التثبيت / Installation
```bash
# استنساخ المشروع
git clone https://github.com/alimuthana222/oilcar-flutter.git
cd oilcar-flutter

# تثبيت المتطلبات
flutter pub get

# إعداد Supabase
# قم بإنشاء مشروع جديد في Supabase وأدخل بيانات الاتصال في:
# lib/core/constants/supabase_config.dart

# تشغيل التطبيق
flutter run
```

### إعداد قاعدة البيانات / Database Setup
```sql
-- إنشاء جدول مواصفات الزيت
CREATE TABLE car_oil_specs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand text NOT NULL,
  model text NOT NULL,
  year_from integer NOT NULL,
  year_to integer NOT NULL,
  engine_type text NOT NULL,
  oil_type text NOT NULL,
  oil_capacity_with_filter numeric NOT NULL,
  oil_capacity_without_filter numeric NOT NULL,
  -- باقي الحقول...
);

-- إدراج بيانات تجريبية
INSERT INTO car_oil_specs (brand, model, year_from, year_to, engine_type, oil_type, oil_capacity_with_filter, oil_capacity_without_filter)
VALUES 
('تويوتا', 'كامري', 2015, 2023, '2.5L 4-Cylinder', '0W-20', 4.4, 4.0),
('هوندا', 'أكورد', 2018, 2023, '1.5L Turbo', '0W-20', 4.4, 4.0),
('نيسان', 'التيما', 2019, 2023, '2.5L 4-Cylinder', '5W-30', 5.4, 5.0);
```

## 🧪 الاختبار / Testing

```bash
# تشغيل الاختبارات
flutter test

# اختبار محدد
flutter test test/vin_validator_test.dart

# تحليل الكود
flutter analyze
```

## 📱 لقطات الشاشة / Screenshots

### الشاشة الرئيسية / Home Screen
- عرض خيارات الإدخال المختلفة
- تصميم Material Design 3
- دعم كامل للعربية مع اتجاه RTL

### مسح VIN / VIN Scanner
- واجهة كاميرا مع إرشادات واضحة
- تقنية OCR لقراءة رقم VIN
- تحقق فوري من صحة الرقم

### الإدخال اليدوي / Manual Input
- نماذج ذكية مع اقتراحات
- فلترة ديناميكية للنماذج والسنوات
- تحقق من صحة البيانات

### عرض النتائج / Results Display
- عرض شامل لمواصفات الزيت
- معلومات تفصيلية عن المحرك
- خيارات المشاركة والتصدير

## 🔧 التطوير المستقبلي / Future Development

### الميزات المخططة / Planned Features
- [ ] تذكيرات تغيير الزيت
- [ ] مقارنة أنواع الزيوت المختلفة
- [ ] دعم تعديلات السيارة
- [ ] وضع عدم الاتصال المحسن
- [ ] تكامل مع متاجر قطع الغيار
- [ ] نظام التقييمات والمراجعات

### التحسينات التقنية / Technical Improvements
- [ ] تحسين أداء OCR
- [ ] ذاكرة تخزين مؤقت أكثر ذكاءً
- [ ] دعم المزيد من APIs
- [ ] تحسين واجهة المستخدم
- [ ] إضافة المزيد من اللغات

## 🤝 المساهمة / Contributing

نرحب بالمساهمات! يرجى اتباع الخطوات التالية:

1. Fork المشروع
2. إنشاء branch جديد (`git checkout -b feature/AmazingFeature`)
3. Commit التغييرات (`git commit -m 'Add some AmazingFeature'`)
4. Push إلى Branch (`git push origin feature/AmazingFeature`)
5. فتح Pull Request

## 📄 الترخيص / License

هذا المشروع مرخص تحت رخصة Apache 2.0 - راجع ملف [LICENSE](LICENSE) للتفاصيل.

## 👨‍💻 المطور / Developer

تم تطوير هذا التطبيق بواسطة فريق تطوير متخصص في تطبيقات Flutter للأسواق العربية.

---

**ملاحظة**: هذا التطبيق في مرحلة التطوير. بعض الميزات قد تحتاج إلى إعداد إضافي أو قد تكون في مرحلة التجريب.

**Note**: This app is under development. Some features may require additional setup or may be in testing phase.