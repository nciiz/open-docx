# محرر خصائص Word

تطبيق مكتبي محلي لعرض وتحرير خصائص ملفات Word بصيغ `.docx` و`.dotx` و`.docm`. واجهته عربية، ويدعم فتح الملف بالسحب أو من قائمة الفتح أو بتمرير مساره إلى التطبيق.

## تثبيت التطبيق على Linux

نزّل AppImage وسكربت التثبيت، ثم شغّل الأوامر التالية من الطرفية. يثبّت السكربت التطبيق في حسابك ويضيفه إلى قائمة التطبيقات باسم **open docx**؛ بعد ذلك يمكنك البحث عنه وتشغيله من القائمة.

```sh
cd ~/Downloads
curl -fL "https://github.com/nciiz/open-docx/releases/download/v1.0.0/Word.Setup-linux.1.0.0.AppImage" -o Word.Setup-linux.1.0.0.AppImage
curl -fL "https://raw.githubusercontent.com/nciiz/open-docx/main/scripts/install-appimage.sh" -o install-open-docx.sh
chmod +x install-open-docx.sh
./install-open-docx.sh "$HOME/Downloads/Word.Setup-linux.1.0.0.AppImage"
```

بعد التثبيت، ابحث في قائمة التطبيقات عن `open docx`. لا تحتاج إلى كتابة أمر التشغيل في كل مرة.

لبناء AppImage من المصدر:

```sh
npm ci
npm run build:appimage
```

سيظهر الملف الناتج داخل مجلد `release/`.

## التشغيل والتطوير

يتطلب Node.js حديثاً و npm. لا يتصل التطبيق بخدمات خارجية أثناء التشغيل. للتطوير نفّذ `npm ci` ثم `npm run desktop`. لتشغيل الاختبارات استخدم `npm test`. لبناء الحزم استخدم `npm run build`؛ تخرج الحزم في `release/`: مثبّت NSIS ونسخة portable على Windows، وحزم DMG/ZIP على macOS وAppImage/DEB على Linux.

## الخط

لا يضمّ المستودع ملفات الخط. انسخ أوزان Thmanyah Sans WOFF2 المرخّصة إلى assets/fonts/ في نسخة العمل المحلية؛ يستخدم التطبيق الخط عند توفره، ويعرض Segoe UI ثم Tahoma ثم system-ui عند غيابه. لا ترفع ملفات الخط إلى المستودع العام؛ راجع الترخيص قبل مشاركة التطبيق المعبأ.

## ما ينفذه الإصدار الحالي

- واجهة RTL أساسية، اختيار الملف، اختصارات الفتح والحفظ والتراجع، وحفظ باسم ونسخة `.bak`.
- قراءة وكتابة خصائص core وapp والخصائص المخصصة والتحقق الأساسي من الأنواع.
- تسجيل أجزاء الخصائص في Content Types وRelationships عند إنشائها.
- تحقق SHA-256 لمحتوى كل جزء غير خاص بالخصائص بعد إعادة فتح الأرشيف.
- تواريخ Windows عبر PowerShell بوسائط منفصلة، وmacOS/Linux عبر `utimes`؛ إنشاء التاريخ على macOS يتطلب SetFile، ولا يدعم Linux تعيينه.

## حدود يجب معرفتها

يحافظ كاتب ZIP على سجلات الملفات المحلية المضغوطة كما هي للعناصر غير المستهدفة؛ يعيد بناء الفهرس المركزي ويستبدل `docProps/*`، ويعدّل `[Content_Types].xml` و`_rels/.rels` عند إضافة جزء فقط. يقارن التطبيق SHA-256 للمحتوى المفكوك لكل عنصر بعد الحفظ. الاختبارات تنشئ حزم OOXML صغيرة، لكنها لا تثبت فتحها في Microsoft Word، ولا تمثل مستندات DOCX واقعية معقدة. اختبر ضبط تواريخ الملفات فعلياً على Windows؛ لم تُختبر تواريخ macOS/Linux أو بناء الحزم لهما.

## البنية

- `electron/`: النافذة الآمنة، IPC، فتح وحفظ الملفات وتواريخ النظام.
- `core/`: قراءة OOXML والتحقق وإعادة كتابة الخصائص وتحويل التواريخ.
- `src/`: واجهة React العربية.
- `tests/`: اختبارات نواة OOXML والتواريخ.
- `assets/`: مصدر أيقونة SVG ومجلد خط محلي اختياري.
